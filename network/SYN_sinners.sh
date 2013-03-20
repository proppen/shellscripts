#!/bin/bash
# This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.
# ----------------------------------------------------------------------------
# 
# Attempt to block out SYN sinners from experiences learned from the big SYN flood attacks against Swedish Government Agencies 2012-09-03.

WAITTIME=9		# How many seconds we want to give legitimate clients before we consider them a SYN flooder
BLOCKTIME=100		# How many seconds we block a client before we remove it from iptables
# DEV="bond2.803"	# Which device to kill tcp connections on (not implemented)


BLOCKDB="/tmp/$(basename $0)-IP-Block.db"
TIME=$(\date +%s)		# Unix epoch time

# 0. Tune the TCP stack, especially the TCP_Fin timeout (reset this to original values after the attack with "sysctl -p")
sysctl -w net.ipv4.tcp_fin_timeout=10	# How long connections are allowed to be half-open
sysctl -w net.ipv4.tcp_keepalive_time=1800
sysctl -w net.ipv4.tcp_window_scaling=0
sysctl -w net.ipv4.tcp_sack=0
sysctl -w net.ipv4.tcp_timestamps=0
sysctl -w net.ipv4.tcp_syncookies=1
sysctl -w net.core.wmem_max=229376	# Buffering, tune this to suit your amount of memory



# 1. Create a temporary list of SYN_RECV connections
TMPLIST="/tmp/$(basename $0).tmplist.$$"
netstat -na | grep ^tcp  | awk '{print $5}' | awk -F: '{print $1}' | sort | uniq > $TMPLIST

# 2. Wait WAITTIME and populate newcomers to blocklist
sleep $WAITTIME
HAXORS=$(netstat -na | grep ^tcp | grep SYN_RECV | awk '{print $5}' | awk -F: '{print $1}' | sort | uniq)

for row in $HAXORS
do
	# Now we add new offenders to the blocklist if they've had open SYN_RECV longer than $WAITTIME
	ip=$(grep $row $TMPLIST)
	if [ -n $ip ]
	then
		echo "$TIME $ip" >> $BLOCKDB
	fi
done


# 3. Manage IPTables
# ToDo: This should really be ported to use ipset instead, this is stupid...
if [ -f $BLOCKDB ]
then
	for ip in $(awk "(\$1 < $(($(\date +%s)-$BLOCKTIME))) {print \$2}" $BLOCKDB | sort | uniq)
	do
	if [ -n $ip ]
	then
		for rule in $(iptables -L -n --line-numbers | grep DROP | grep "$ip" | awk '{print $1}')
		do
			if [ -n $ip ]
			then
				echo "/sbin/iptables -D INPUT $rule"
				/sbin/iptables -D INPUT $rule
				sed -i "/^$rule/d" $BLOCKDB
			fi
		done
	fi
	done

	# 3. Get IPs from list newer than BLOCKTIME if the ip isn't already in iptables. (rotate this from an outisde process)
	for ip in $(awk "(\$1 > $(($(\date +%s)-$BLOCKTIME))) {print \$2}" $BLOCKDB | sort | uniq)
	do
		#if [[ -n $ip ]] && [[ "$ip" != "$(iptables -L -n | grep DROP | grep $ip  | awk '{print $4}')" ]]
		# If we don't have a rule for ip in iptables
		if [ "$ip" != "$(iptables -L -n | grep DROP | grep $ip  | awk '{print $4}')" ]
		then
			# When the address is added, you'll have to wait for as long as net.ipv4.tcp_fin_timeout says
			echo "/sbin/iptables -I INPUT -s $ip -j DROP"
			/sbin/iptables -I INPUT -s $ip -j DROP

			# Is it possible to kill half-open connections somehow?
			#echo "Killing TCP connections to $ip"
			#tcpkill -i $DEV host $ip &> /dev/null &
			#sleep 1
			#killall tcpkill
		fi
	done
fi


if [ -f $TMPLIST ]
then
	rm -f $TMPLIST 
fi


#!/bin/bash

function sysctl_set
{
# arg1 = CES Chapter number, eg. "4.1.1"
# arg2 = sysctl_variable, eg "net.ipv4.ip_forward"
# arg3 = wanted value, eg "0"

VALUE=$(/sbin/sysctl $2|awk '{print $3}')

if [ $VALUE != $3 ]
then
	echo "CES $1 Warning - Setting $2 to $3"
	/sbin/sysctl -w $2=$3
	echo "$2 = $3" >> /etc/sysctl.conf
else
	echo "CES $1 OK - $2 already set to $3"
fi
}

function kernmod_disable
{
# arg1 = CES Chapter number
# arg2 = CES Chapter name, eg "Disable SCTP"
# arg3 = modprobe configuration file string to look for/insert if nonexisting, eg "install rds /bin/true" (dont forget the quotes)
CHECK=$(grep "$3" /etc/modprobe.d/*)
if [ -z "$CHECK" ]
then
	echo "CES RHEL $1 Warning - $2: Kernel module $3 is enabled. Disabling it..."
	echo "$3" >> /etc/modprobe.d/CIS.conf

else
	echo "CES RHEL $1 OK - $2"
fi
}

# 4.1.1 Disable IP Forwarding
sysctl_set 4.1.1 net.ipv4.ip_forward 0

# 4.1.2 Disable Send Packet Redirects - unknown key for CentOS 6
#sysctl_set 4.1.2 net.ipv4.conf.all.send_redirects 0
#sysctl_set 4.1.2 net.ipv4.conf.send_redirects 0

# 4.2.1 Disable Source Routed Packet Acceptance
# Description:
# In networking, source routing allows a sender to partially or fully specify the route packets
# take through a network. In contrast, non-source routed packets travel a path determined
# by routers in the network. In some cases, systems may not be routable or reachable from
# some locations (e.g. private addresses vs. Internet routable), and so source routed packets
# would need to be used
sysctl_set 4.2.1 net.ipv4.conf.all.accept_source_route 0
sysctl_set 4.2.1 net.ipv4.conf.default.accept_source_route 0

# 4.2.2 Disable ICMP Redirect Acceptance
sysctl_set 4.2.2 net.ipv4.conf.all.accept_redirects 0
sysctl_set 4.2.2 net.ipv4.conf.default.accept_redirects 0

# 4.2.4 Log Suspicious Packets
sysctl_set 4.2.4 net.ipv4.conf.all.log_martians 1

# 4.2.5 Enable Ignore Broadcast Requests
sysctl_set 4.2.5 net.ipv4.icmp_echo_ignore_broadcasts 1

# 4.2.6 Enable Bad Error Message Protection
sysctl_set 4.2.6 net.ipv4.icmp_ignore_bogus_error_responses 1

# 4.2.7 Enable RFC-recommended Source Route Validation
sysctl_set 4.2.7 net.ipv4.conf.all.rp_filter 1
sysctl_set 4.2.7 net.ipv4.conf.default.rp_filter 1

# 4.2.8 Enable TCP SYN Cookies
sysctl_set 4.2.8 net.ipv4.tcp_syncookies 1

# Flush routes
/sbin/sysctl -w net.ipv6.route.flush=1


# 4.4 Disable IPv6
kernmod_disable 4.4.1 "Disable IPv6" "options ipv6 \"disable=1\""

# 4.4.2 - Configure IPv6 - Disabled because we don't want to use it right now.

# 4.5 Install TCP Wrappers - We're skipping this part.
# Description:
# TCP Wrappers provides a simple access list and standardized logging method for services
# capable of supporting it. In the past, services that were called from inetd and xinetd
# supported the use of tcp wrappers. As inetd and xinetd have been falling in disuse, any
# service that can support tcp wrappers will have the libwrap.so library attached to it.
# Rationale:
# TCP Wrappers provide a good simple access list mechanism to services that may not have
# that support built in. It is recommended that all services that can support TCP Wrappers,
# use it

# 4.6 Enable IPtables - Skipping this
# 4.7 Enable IP6tables - Skipping this

# 4.8.2 Disable SCTP
# The Stream Control Transmission Protocol (SCTP) is a transport layer protocol used to
# support message oriented communication, with several streams of messages in one
# connection. It serves a similar function as TCP and UDP, incorporating features of both. It is
# message-oriented like UDP, and ensures reliable in-sequence transport of messages with
# congestion control like TCP
kernmod_disable 4.8.2 "Disable SCTP" "install sctp /bin/true"


# 4.8.3 Disable RDS
# The Reliable Datagram Sockets (RDS) protocol is a transport layer protocol designed to
# provide low-latency, high-bandwidth communications between cluster nodes. It was
# developed by the Oracle Corporation.
kernmod_disable 4.8.3 "Disable RDS" "install rds /bin/true"

# 4.8.4 Disable TIPC
kernmod_disable 4.8.4 "Disable TIPC" "install tipc /bin/true"

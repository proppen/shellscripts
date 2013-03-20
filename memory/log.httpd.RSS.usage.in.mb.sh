#!/bin/bash
# Tom Molin, 2010-09-03
# Logs (in megabytes) how much memory is used by all processes with the same name
#
# The head of the csv file should be
# "Date<tab><tab>Time<tab>Procname<tab><tab>Size(MB)"


LOGFILE="/home/tom/logs/apacheMBusagelog.csv"
PROCNAME="httpd"								# Process name to count mem usage for
NRPROCS="`bin/httpdprocs.sh`"
DATE="`\date "+%F	%R"`"


RESKB=`ps -o rss -C $PROCNAME| tail -n +2 | (sed 's/^/x+=/'; echo x) | bc`	# Count how many KB is used for each process with the same name
RESMB=`echo "$RESKB/1024"|bc`							# Let bc convert it to Megabytes.

#echo $RESMB | $TEE $LOGFILE							# Show the contents 
if [ "$1" == "--stdout" ]; then
	TEE="tee -a"								# Copy output to both stdout and logfile if run with --stdout arg
	echo -e "$DATE\t$PROCNAME\t\t$RESMB\t\t$NRPROCS" | $TEE $LOGFILE						# Show & log the sum
else
	echo -e "$DATE\t$PROCNAME\t\t$RESMB\t\t$NRPROCS" >> $LOGFILE							# Log the sum
fi

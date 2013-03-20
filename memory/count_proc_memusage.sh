#!/bin/bash
# Tom Molin, 2012-04-10
# Prints (in megabytes) how much memory is used by all processes with the same name
#


PROCNAME="$1"								# Process name to count mem usage for
DATE="`\date "+%F	%R"`"


#RESKB=`ps -o rss -C $PROCNAME| tail -n +2 | (sed 's/^/x+=/'; echo x) | bc`	# Count how many KB is used for each process with the same name
RESKB=`ps -o size -C $PROCNAME| tail -n +2 | (sed 's/^/x+=/'; echo x) | bc`	# Count how many KB is used for each process with the same name
#RESKB=`ps -o vsize -C $PROCNAME| tail -n +2 | (sed 's/^/x+=/'; echo x) | bc`	# Count how many KB is used for each process with the same name
RESMB=`echo "$RESKB/1024"|bc`							# Let bc convert it to Megabytes.

#echo -e "$DATE\t$PROCNAME\t\t$RESMB"
echo -e "$RESMB\t$PROCNAME"

#!/bin/bash
# $Id: report.classes.in.debug-mode.sh 171 2010-10-25 06:23:15Z tom.molin $
# Creates a report of DEBUG reporting classes in a JBoss logfile. Use Root log if no argument is used.

if [[ -z "$1" ]]; then
	ROOTLOG=~/log/transnet/logs/root_logger.txt
else
	ROOTLOG=$1
fi

nice -n 19 awk '{print $3, $4}' $ROOTLOG |nice -n 19 grep ^DEBUG | nice -n 19 sort |nice -n 19 uniq -c|sort -n

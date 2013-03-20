#!/bin/bash
# $Id: report.classes.that.produces.errors.in-rootlog.sh 166 2010-10-22 08:56:55Z tom.molin $
# Creates a report of ERROR reporting classes in a jboss logfile


ROOTLOG=~/log/transnet/logs/root_logger.txt

nice -n 19 awk '{print $3, $4}' $ROOTLOG |nice -n 19 grep ^ERROR | nice -n 19 sort |nice -n 19 uniq -c|sort -n

#!/bin/bash
# $Id: jmap.sh 166 2010-10-22 08:56:55Z tom.molin $
# Check jmap heap info for JBoss
# Tom Molin, 2010-06-21

WARNLEVEL=99

function float_eval()
# Workaround for BASHs inability to compare floating points... using bc instead :P
{
	case `echo "a=$WARNLEVEL;b=$1;r=-1;if(a==b)r=0;if(a>b)r=1;r"|bc` in
	   0)
		# $WARNLEVEL and b=$b are equal
	;;
	   1)
		# $WARNLEVEL is bigger than b=$1
	;;
	   *)
		echo Garbage generation $i is less than b=$1
		WARNING=1
	;; esac
}


if [ "$1" == "--percentage" ]; then

	PERC=`/home/jboss/bin/jmap.sh 2> /dev/null |grep '%'|awk '{print $1}' | sed 's/%$//g'`
	i=0
	for x in $PERC
		do
		i=`expr $i + 1`
		float_eval $x
		done
	exit 0
fi

/usr/java/jdk/bin/jmap -heap `~/bin/jbossctrl pid`

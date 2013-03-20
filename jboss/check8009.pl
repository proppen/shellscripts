#!/usr/bin/env perl
#-----------------------------------
# Written by Tom Molin 2009-09-02
#-----------------------------------
# Crontab script to find out how close we are
# to run out of 8009 ports to the web balancer.
# If $WARNLEVEL is reached it will send a warning email.
#

# Where do I find server.xml? It parses for the maximum # of threads allowed
my $SERVERXML="/opt/jboss/server/transnet/deploy/jbossweb-tomcat55.sar/server.xml";
my $HOSTNAME=`hostname`; chomp $HOSTNAME;

my $EMAIL="operations@example.net";		# Where I send warning emails

my $WARNSUB="$HOSTNAME Threadpool warning";	# Subject field in warning email
my $WARNLEVEL="70";



if(-r "$SERVERXML")
{
	# Parse server.xml for maxThreads on port $PORT
	my $MAXTHREADS=`grep -A6  'Connector port="8009"' $SERVERXML | grep maxThreads | awk -F\= '\{print \$2\}' | sed 's/"//g'`;
	chomp $MAXTHREADS;

	# Get info on how many 8009 connections we have
	my $PORTS=`netstat -na|grep 8009|grep ESTABLI|wc -l`;
	$PORTS =~ s/^\s+//; $PORTS =~ s/\s+$//;		# Remove any leading and trailing whitespaces

	my $PERCENT=($PORTS*100/$MAXTHREADS);
	$PERCENT =~ s/^\s+//; $PERCENT =~ s/\s+$//; 	# Remove any leading and trailing whitespaces

	if ($PERCENT >= $WARNLEVEL)
	{
		my $EXEC="echo Warning, JBoss is using $PERCENT percent of its threads on $HOSTNAME. See http://wiki.company.se/mywiki/Memnon_Operations_Handbook/Known_Errors/Other_Warnings_and_Errors for further information.\| mail $EMAIL -s \"$WARNSUB\"";
		system ("$EXEC");
		exit 0;
	}
	if ($PERCENT eq 0)
	{
		print "Warning! JBoss don't seem to use any threads! Is it running on $HOSTNAME?\n";
		exit 0;
	}
}

else
{
	print "Could not read $SERVERXML. Aborting...\n";
	exit 1;
}


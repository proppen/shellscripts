#!/usr/bin/env perl
#
# Count the number of error messages in GREPFILE the last hour
# Writes to $LOGFILE if not overridden by --logfile= -alias
# Tom Molin, 2010-02-11
#
use Getopt::Long;

my $DATE=`\date +%F`; chomp $DATE;
my $HOUR=`\date -d "1 hour ago" +%H`; chomp $HOUR; # Check how many errors we had last hour
my $GREPFILE="/home/jboss/log/transnet/logs/root_logger.txt"; chomp $GREPFILE;
my $LOGFILE="/home/jboss/log/errorstats.log"; # Unless overridden by --logfile
my $CMD="nice -n 19 grep ^\'$DATE $HOUR:\' $GREPFILE \| awk \'\{print \$3\}\' \| grep ERROR \| wc -l";


GetOptions (	"logfile=s"	=> \$LOGCHOISE,				# --logfile=[PATH]
		"help"		=> \$HELP );				# --help
chomp $LOGCHOISE,;

if ( $LOGCHOISE )
	{ $LOGFILE = $LOGCHOISE };

open (LOG,">>$LOGFILE"); 
print LOG "$DATE-$HOUR:59;";
open (SYSTEM, "$CMD |");
while (<SYSTEM>) {
	print LOG $_;
}       
close SYSTEM;
close LOG;

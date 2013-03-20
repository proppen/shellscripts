#!/usr/bin/perl
# 2012-04-11 tom.molin
# 
# Search for files (faster than unix find) older than --weeksold=N in --path={string}


use File::Copy;
use File::Find;
use File::Basename;
use Getopt::Long;
use Time::Local;

GetOptions (    "path=s"	=> \$DIR,
		"weeksold=n"	=> \$WEEKS);


#my $FILENAME="*";							# The name of the file we want to search/rotate

# Take the first program argument as path to scavenge
if ( ! defined $DIR ){  die "Please specify a folder that I should traverse (--path=)\n" } ;
if ( ! defined $WEEKS ) { die "Please specify the age (in weeks) of files I should look for (--weeksold=)\n" };



s|(?<!/)\z|/| for $DIR;							# Add a trailing slash to DIR if it doesn't exist

$AGE = (time() - ($WEEKS*3600*24*7));
#print "Searching for files in $DIR older than $AGE\n";

find \&wanted, "$DIR";


sub wanted
{
	my $dev;         # the file system device number
	my $ino;         # inode number
	my $mode;        # mode of file
	my $nlink;       # counts number of links to file
	my $uid;         # the ID of the file's owner
	my $gid;         # the group ID of the file's owner
	my $rdev;        # the device identifier
	my $size;        # file size in bytes
	my $atime;       # last access time
	my $mtime;       # last modification time
	my $ctime;       # last change of the mode
	my $blksize;     # block size of file
	my $blocks;      # number of blocks in a file
	# Right below here you can tell lstat to retrieve all this info on each and every file/directory.  Each and every file/directory is written to $_.
	# Keeping this as an example, but to save time we don't need this info
#	if ( $_ eq $FILENAME )
#	{
		(($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = lstat($_));
#		(($mtime) = lstat($_));
		my $READFILE = "$File::Find::name";			# The file I found
		if ( $mtime lt $AGE )
		{
			# Only print real files
			if ( -f $READFILE )
			{
				print "$READFILE\n";
			}
		
			# Convert UNIX epoch to readable time
			#my $time = time;    # or any other epoch timestamp
			#my @months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
			#my ($sec, $min, $hour, $day,$month,$year) = (localtime($mtime))[0,1,2,3,4,5];
			# You can use 'gmtime' for GMT/UTC dates instead of 'localtime'
			#my $DATETIME="$months[$month] $day ". ($year+1900);
			#print "| $DATETIME\n";
		}
#	}

}

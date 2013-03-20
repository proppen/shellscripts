#!/usr/bin/perl
# $Id: find-rotatefiles.pl 236 2011-03-16 12:01:32Z tom.molin $
# 
# Search, copy, compress and truncate files recursivley, faster than unix find.
# Tom Molin

use File::Copy;
use File::Find;
use File::Basename;
use Getopt::Long;

GetOptions (    "name=s"	=> \$FILENAME,						# --name=filename
		"uid=s"		=> \$UID,
		"dir=s"		=> \$DIR);


#my $FILENAME="*";							# The name of the file we want to search/rotate

# Take the first program argument as path to scavenge
if ( ! defined $DIR ){  die "Please specify a folder that I should traverse (--dir=)\n" } ;
#if ( ! defined $FILENAME ) { die "Please specify a filename that I should search for (--name=)\n" };



s|(?<!/)\z|/| for $DIR;							# Add a trailing slash to DIR if it doesn't exist

print "Performing recursive search for files in $DIR\n\n";
print "FileName | uid | size(bytes) | ChangeDate\n";
print "==============================\n";
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
		my $READFILE = "$File::Find::name";			# The file I found
		if ( $uid ne 1000 )
		{
			print "$READFILE | " . getpwuid($uid) . " | $size ";
		
			# Convert UNIX epoch to readable time
			#my $time = time;    # or any other epoch timestamp
			my @months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
			my ($sec, $min, $hour, $day,$month,$year) = (localtime($mtime))[0,1,2,3,4,5];
			# You can use 'gmtime' for GMT/UTC dates instead of 'localtime'
			my $DATETIME="$months[$month] $day ". ($year+1900);
			print "| $DATETIME\n";
		}
#	}

}

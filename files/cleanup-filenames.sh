#!/usr/bin/env bash
# This script converts filenames from ISO 8859-1 to UTF-8.
# Also removes characters in files (but not dirs) defined by STRIPSIGNS.
# Tom Molin, 2010-06-28
# Tom Molin, 2010-06-28
#

FILEPATH="/home/ftp/"
CONVMV="/root/bin/convmv"
STRIPSIGNS="å Å ä Ä æ Æ ö Ö ø Ø"       			# Space-separated signs to strip
BATCH="/tmp/findfiles.sh"				# Batch file to execute later


function findfiles {
# First build the find statement from STRIPSIGNS
count=0
for c in $STRIPSIGNS
        do
                if [ $count == 0 ]; then
                        FINDS="$FINDS -type f -iname '*$c*'"
                else
                        FINDS="$FINDS -o -type f -iname '*$c*'"
                fi
                let count++
        done
FINDS="$FINDS\n"
# Make a batch/log file and execute it
if [ -a "$BATCH" ]; then
	mv "$BATCH" "$BATCH.`date +%F-%R`"
fi
echo -n "# Job run " > $BATCH && date >> $BATCH && echo "find $FILEPATH $FINDS" >> $BATCH  &&\
bash $BATCH
}


function iso2utf8 {
# Convert filenames from ISO-8859-1 to UTF-8 
	if [ -n "$FILEPATH" ]; then
		$CONVMV -f iso-8859-1 -t UTF-8 -r --notest $FILEPATH 2> /dev/null
	else
		echo "you must define a FILEPATH to convert filenames to UTF8"
	fi
}


function stripchars {
# Takes a string as input and returns it stripped from signs in STRIPSIGNS
	basename "$*" | sed "s/[$STRIPSIGNS]/./g"
}


##
## "Main" part below
##

iso2utf8 $FILEPATH					# Convert files to utf8
findfiles | while read file				# Find files with STRIPSIGNS in them (escape spaces)
do
	file=`echo $file`
	basefile=`basename "$file" | sed 's/ /\\ /g'`
	directory=`dirname "$file" | sed 's/ /\\ /g'`
	DEST="$directory/`stripchars $basefile`"	# Concatenate the string. Remove forbidden chars in filename - do not change directory names
	if [ -a "$DEST" ]; then
		echo "ERROR $DEST already exists while trying to rename $file to $DEST!"
		exit 1
	fi
	cd "$directory"
	echo cd "$directory" >> $BATCH
	mv "$basefile" "$DEST"				# Rename the files
	echo mv "$basefile" "$DEST" >> $BATCH
done

#!/bin/bash
# Copyright 2013, Tom Molin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


URL=""					# The URL to check for changes
EMAIL=""
INTERVAL="30"				# Seconds between loops
checkdir="/tmp"
checkfile="$checkdir/regeringen.se-check"
###################################

function checkmd5
# Returns 1 if supplied checksum is found
{
	findfile=$(echo $checkfile | awk -F/ '{print $NF}')					# Get filename pattern to search for below
	histfiles="$(find $checkdir -name "$findfile.*.*" -cmin -30)"				# Create a history list of old files 
	for file in $histfiles
	do
		md5sum=$(md5sum $file|awk '{print $1}')
		md5list="$md5list $md5sum"
	done
	#echo "$md5list"
	for n in $md5list
	do
		if [[ "$1" == "$n" ]] || [[ "$1" == "$2" ]]
		then
			echo $1 is a known checksum for $URL
			return 1
		fi
	done
	return 0
}

function cleanoldfiles
# Clean up old web downloaded pages
{
	find $checkdir -name "$findfile.*.*" -cmin +1440 -exec rm -f {} \;
}

while true
do
	old=$(md5sum $checkfile.2 | cut -f1 -d" ")
	curl -s $URL > $checkfile.1
	new=$(md5sum $checkfile.1 | cut -f1 -d" ")
	#echo "$URL $new"
	now=$(date +%s)
	
	# Exit loop if it's a known checksum (otherwise proceed)
	checkmd5 $old $new && if [ "$old" != "$new" ]
	then
		D=$(date +%s)
		cp $checkfile.1 $checkfile.1.$D
		checksum1=$(md5sum $checkfile.1.$D | cut -d " " -f1)

		cp $checkfile.2 $checkfile.2.$D
		checksum2=$(md5sum $checkfile.2.$D | cut -d " " -f1)
			# Build an email with attachments
			(
			echo "File checksums:"
			echo "$(md5sum $checkfile.1.$D)"
			echo "$(md5sum $checkfile.2.$D)"
			echo ""
			echo "This message were generated at $HOSTNAME by $0."
			uuencode $checkfile.1.$D $checkfile.1.$D.txt
			uuencode $checkfile.2.$D $checkfile.2.$D.txt
			)\
				|mail -s "INFO - Content in $URL changed" $EMAIL
			echo             "INFO - Content in $URL changed to $new"
#		fi
	fi
	cp -f $checkfile.1 $checkfile.2
	sleep $INTERVAL
	cleanoldfiles
done

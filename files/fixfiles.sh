#/bin/bash
# Search for files compressed over and over again because of misconfigured logrotate script
# Count how many times it has been compressed and uncompress it this many times
# Rename the file so that RKUtil app gets the correct filename, then compress it again.
#
# Tom Molin, tom.molin@gmail.com
# Mogul Services 2013-04-10

#Fix folder, where we search for files rotated/compressed over and over
FixFolder="/opt/syslog/Server/"

# Don't do anything with todays file
Y=$(date +%Y)
M=$(date +%m)
D=$(date +%d)

function gzfilename()
{
# Rename a file to its last .gz extention, return the filename
	# What the name should be (remove everything after the last .gz)
        ugz=$(echo $1|sed 's/[^\.gz]*$//')
        # Clean up filename
        if [ "$1" != "$ugz" ]
        then
          mv $1 $ugz
        fi
	echo "$ugz"
}

function move()
{
	if [ "$1" != "$2" ]
	then
		mv $1 $2
	fi
}

# Unpack the file as many times as needed, but not todays file
find "$FixFolder" -type f -name "mail*.gz" |grep -v "$Y/$M/$D" | while read file
do
	# How many times has the file been compressed?
	TIMES=$(echo "$(echo $file | sed 's/\.gz/\n/g' | wc -l) -1"|bc)
	dir=$(dirname $file)

	cd "$dir"
	for x in $(seq $TIMES)
	do
		# What's our filename now?
		f=$(ls $(dirname $file)|grep \.gz | tail -1)

		# What the name should be (remove everything after the last .gz)
		#fgz=$(echo $f|sed 's/[^\.gz]*$//')

		# Clean up filename if needed
		fgz=$(gzfilename "$f")
		echo "$fgz"
		gunzip "$fgz"
	done
	#find "$dir" -type f -name "mail????????-????????" -not -name "*.gz" | grep -v "$Y/$M/$D" | while read f
	find "$dir" -type f -name "mail????????-???????*" -not -name "*.gz" | grep -v "$Y/$M/$D" | while read f
	do
		file=$(basename "$f")
		newfile="$(echo $file|awk -F- '{print $1}')"
		#  Remove the first dash and everything after unless the filename contains gz
		move "$file" "$newfile" &&\
		gzip -v "$newfile"

	done
done

# compress any old uncompressed mail logs unless todays date
find "$FixFolder" -type f -name "mail???????*" -not -name "*.gz" | grep -v "$Y/$M/$D" | while read f
do
	dir=$(dirname "$f")
	file=$(basename "$f")
	newfile="$(echo $file|awk -F- '{print $1}')"
	cd $dir
	# Remove the first dash and everything after unless the filename contains gz
	#echo "$file"| grep \.gz || mv "$file" "$newfile"
	move "$file" "$newfile" &&\
	gzip -v "$newfile"
	
done

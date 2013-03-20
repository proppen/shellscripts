#!/bin/bash


grep HISTTIMEFORMAT /etc/bashrc > /dev/null &&
(
	echo "Timestamps OK - Timestamps is saved in command history."
) ||
(
	echo "Timestamps Warning - Adding timestamps to command history."
	(
cat << 'EOF'

if [ "$PS1" ]; then
    HISTTIMEFORMAT='%F %T '	# Set nice history timestamps on 
fi

EOF
)

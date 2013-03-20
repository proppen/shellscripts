#!/bin/bash
# These checks are for 64 bit systems only.

function check_installed
{
# Run like check_installed <pkg> && true || false
        yum list $1 |grep Installed > /dev/null
}

# 5.1.1 - 5.1.4 Syslogd - CentOS 6 uses rsyslog, steps not needed...

# 5.2 Configure rsyslog instead of syslog
# 5.2.1 Install the rsyslog package

check_installed rsyslog &&
(
        echo "CES 5.3.1 OK - rsyslog is installed"
) ||\
(
        echo "CES 5.2.1 Warning - Installing rsyslogd"
        yum -y install rsyslog
)

# 5.2.2 Activate rsyslogd
echo "CES 5.2.2 OK - Disabling syslog"
chkconfig syslog off
echo "CES 2.5.5 OK - Enabling rsyslog"
chkconfig rsyslog on

# 5.2.3 Define a rsyslog config file
if [ -f /etc/rsyslog.conf ]
then
	mv /etc/rsyslog.conf /etc/rsyslog.conf.$(/bin/date +%F.%s)
fi
(
cat << 'EOF'
auth,user.*		/var/log/messages
kern.*			/var/log/kern.log
daemon.*		/var/log/daemon.log
syslog.*		/var/log/syslog
lpr,news,uucp,local0,local1,local2,local3,local4,local5,local6.*		"

# Execute the following command to restart syslogd
# pkill -HUP syslogd

EOF
) > /etc/rsyslog.conf

# 5.2.4 Create and Set Permissions on rsyslog Log Files
# A log file must exist for rsyslog to be able to write to it.
echo "CES 5.2.4 OK - Create/set permissions on rsyslog log files"
LOGFILES="/var/log/messages /var/log/kern.log /var/log/daemon.log /var/log/syslog /var/log/unused.log"
for f in $LOGFILES
do
	touch $f
	chown root:root $f
	chmod og-rwx $f
done

# 5.2.5 Configure rsyslog to send logs to remote host
echo -n "CES 5.2.5 "
grep "^*.*[^I][^I]*@" /etc/rsyslog.conf > /dev/null && echo -n "OK - rsyslog is" ||echo -n "Warning - rsyslog NOT"
echo "configured to send logs to remote host"

# 5.2.6 Disable rsyslog messages over the network
echo "CES 5.2.6 OK - Disabling rsyslog recieving messages via network"
sed -i 's/^$ModLoad/#$ModLoad/g' /etc/rsyslog.conf
sed -i 's/^$InputTCPServerRun/#$InputTCPServerRun/g' /etc/rsyslog.conf

# 5.3.1 Enable auditd Service
# Turn on the auditd daemon to record system events.
echo "CES 5.6.7 OK - Enable auditd"
chkconfig auditd on

# 5.3.2.1 Set auditd data retention to 20MB
echo "CES 5.3.2.1 OK - Setting auditd Data retention to 20MB"
sed -i 's/^max_log_file = [0-900]/max_log_file = 20/g' /etc/audit/auditd.conf

# 5.3.2.2 Disable system on audit log full - We won't enable this...

# 5.3.2.3 Keep Auditing Information
echo "CES 5.3.2.3 OK - Keeping old versions of the audit log"
sed -i 's/max_log_file_action = ROTATE/max_log_file_action = keep_logs/g' /etc/audit/auditd.conf

# 5.3.3 Enable Auditing for Processes That Start Prior to auditd
egrep -v ^# /etc/grub.conf|egrep '(*.kernel)'|egrep '(audit=1)' > /dev/null && echo "CES 5.3.3 OK - Auditing for processes started prior to auditd is enabled" || echo "CES 5.3.3 Warning - Auditing for processes started prior to auditd is NOT enabled"

# 5.3.4 Record Events That Modify Date and Time Information
grep time-change /etc/audit/audit.rules > /dev/null && echo "CES 5.3.4 OK - Auditd records DateTime change events" ||\
(
	(
	cat << 'EOF'
# 5.3.4 Record Events That Modify Date and Time Information
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change
-a always,exit -F arch=b32 -S clock_settime -k time-change
-w /etc/localtime -p wa -k timechange
EOF
	) >> /etc/audit/audit.rules
)

# 5.3.5 Record Events That Modify User/Group Information
grep identity /etc/audit/audit.rules | egrep '(group|passwd|gshadow|opasswd)' > /dev/null && 
(
	echo "CES 5.3.5 OK - auditd logs events in group|passwd|gshadow|opasswd"
) ||\
(
	echo "CES 5.3.5 Warning - Adding Event recording of group|passwd|gshadow|opasswd to /etc/audit/audit.rules"
	(
	cat << 'EOF'
# 5.3.5 Record Events That Modify User/Group Information
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p wa -k identity

EOF
	) >> /etc/audit/audit.rules
)

# 5.3.6 Record Events That Modify the System’s Network Environment
grep system-locale /etc/audit/audit.rules > /dev/null &&
(
	echo "CES 5.3.6 OK - Events that modify systems network environment is enabled"
) ||
(
	echo "CES 5.3.6 Warning - Adding monitoring of changes in systems network environment"
	(
	cat << 'EOF'
# 5.3.6 Record Events That Modify the System’s Network Environment
-a exit,always -F arch=b64 -S sethostname -S setdomainname -k system-locale
-a exit,always -F arch=b32 -S sethostname -S setdomainname -k system-locale
-w /etc/issue -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/sysconfig/network -p wa -k system-locale

EOF
	) >> /etc/audit/audit.rules
)

# 5.3.7 Record Events That Modify the System’s Mandatory Access Controls
grep MAC-policy /etc/audit/audit.rules > /dev/null &&
(
	echo "CES 5.3.7 OK - Events that modify /etc/selinux/ is logged."
) ||
(
	echo "CES 5.3.7 Warning - Adding monitoring of /etc/selinux/"
	(
	cat << 'EOF'
# 5.3.7 Record Events That Modify the System’s Mandatory Access Controls
-w /etc/selinux/ -p wa -k MAC-policy

EOF
	) >> /etc/audit/audit.rules
)

# 5.3.8 Collect Login and Logout Events
grep logins /etc/audit/audit.rules > /dev/null &&
(
	echo "CES 5.3.8 OK - Login/logout events is monitored."
) ||
(
	echo "CES 5.3.8 Warning - Adding monitoring of logins/logouts"
	(
	cat << 'EOF'
# 5.3.8 Collect Login and Logout Events
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins
-w /var/log/tallylog -p -wa -k logins
-w /var/log/btmp -p wa -k session

EOF
	) >> /etc/audit/audit.rules
)

# 5.3.9 Collect Session Initiation Information
grep session /etc/audit/audit.rules > /dev/null &&
(
	echo "CES 5.3. OK -  Session initiation events is monitored."
) ||
(
	echo "CES 5.3. Warning - Adding monitoring of session initiation events. "
	(
	cat << 'EOF'
# 5.3.9 Collect Session Initiation Information
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k session

EOF
	) >> /etc/audit/audit.rules
)

# 5.3.10 Collect Discretionary Access Control Permission Modification Events
grep perm_mod /etc/audit/audit.rules > /dev/null &&
(
	echo "CES 5.3. OK - chown, fchown, fchownat and lchown system calls is monitored."
) ||
(
	echo "CES 5.3. Warning - Adding monitoring of chown, fchown, fchownat and lchown system calls."
	(
	cat << 'EOF'
# 5.3.10 Collect Discretionary Access Control Permission Modification Events
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=500 \
-F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=500 \
-F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F
auid>=500 \
-F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F
auid>=500 \
-F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S
removexattr -S \
lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S
removexattr -S \
lremovexattr -S fremovexattr -F auid>=500 -F auid!=4294967295 -k perm_mod

EOF
	) >> /etc/audit/audit.rules
)

# 5.3.11 Collect Unsuccessful Unauthorized Access Attempts to Files
grep access /etc/audit/audit.rules > /dev/null &&
(
	echo "CES 5.3. OK - Unsuccessful Unauthorized Access Attempts to Files is monitored."
) ||
(
	echo "CES 5.3. Warning - Adding monitoring of Unsuccessful Unauthorized Access Attempts to Files."
	(
	cat << 'EOF'
# 5.3.11 Unsuccessful Unauthorized Access Attempts to Files
-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate \
-F exit=-EACCES -F auid>=500 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate \
-F exit=-EACCES -F auid>=500 -F auid!=4294967295 -k access
-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate \
-F exit=-EPERM -F auid>=500 -F auid!=4294967295 -k access
-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate \
-F exit=-EPERM -F auid>=500 -F auid!=4294967295 -k access

EOF
	) >> /etc/audit/audit.rules
)

# 5.3.12 Collect Use of Privileged Commands
echo "CES 5.3.12 OK - Collecting list of Privileged Commands and adding monitoring for their usage."
MOUNTPOINTS=$(awk '{print $2}' /etc/fstab |grep ^/|egrep -v '(^/sys|^/proc|^/dev)')

# Remove the old lines
sed -i '/Start 5.3.12 Collect Use of Privileged Commands/,/End 5.3.12 Collect Use of Privileged Commands/d' /etc/audit/audit.rules

# Add the new lines
echo -e "# Start 5.3.12 Collect Use of Privileged Commands" >> /etc/audit/audit.rules
for filesys in $MOUNTPOINTS
do
	find $filesys -xdev \( -perm -4000 -o -perm -2000 \) -type f | awk '{print "-a always,exit -F path=" $1 " -F perm=x -F auid>=500 -F auid!=4294967295 -k privileged" }' >> /etc/audit/audit.rules 
done
echo -e "# End 5.3.12 Collect Use of Privileged Commands" >> /etc/audit/audit.rules


# 5.3.13 Track Successful File System Mounts
grep mounts /etc/audit/audit.rules > /dev/null &&
(
	echo "CES 5.3. OK - Mounting of file systems is monitored."
) ||
(
	echo "CES 5.3. Warning - Adding monitoring of Successful filesystem mounts."
	(
	cat << 'EOF'
# 5.3.13 Collect Successful File System Mounts
-a always,exit -F arch=b64 -S mount -F auid>=500 -F auid!=4294967295 -k mounts
-a always,exit -F arch=b32 -S mount -F auid>=500 -F auid!=4294967295 -k mounts

EOF
	) >> /etc/audit/audit.rules
)


# 5.3.14 Collect File Deletion Events by User
grep delete$ /etc/audit/audit.rules > /dev/null &&
(
	echo "CES 5.3.14 OK - Monitoring of file deletion events is active."
) ||
(
	echo "CES 5.3.14 Warning - Adding monitoring of file deletion events."
	(
	cat << 'EOF'
 # 5.3.14 Collect File Deletion Events by User
-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=500 -F auid!=4294967295 -k delete
-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=500 -F auid!=4294967295 -k delete

EOF
	) >> /etc/audit/audit.rules
)

# 5.3.15 Collect Changes to system administration scope (sudoers)
grep scope /etc/audit/audit.rules > /dev/null &&
(
	echo "CES 5.3.15 OK - Sudoers changes is monitored."
) ||
(
	echo "CES 5.3.15 Warning - Adding monitoring sudo changes."
	(
	cat << 'EOF'
# 5.3.15 Collect Changes to system administration scope (sudoers)
-w /etc/sudoers -p wa -k scope

EOF
	) >> /etc/audit/audit.rules
)

# 5.3.16 Collect System Administrator Actions (sudolog)
# Description: Monitor the sudo log file. If the system has been properly configured to disable the use of
# the su command and force all administrators to have to log in first and then use sudo to
# execute privileged commands, then all administrator commands will be logged to
# /var/log/sudo.log. Any time a command is executed, an audit event will be triggered
# as the /var/log/sudo.log file will be opened for write and the executed
# administration command will be written to the log.
grep actions /etc/audit/audit.rules > /dev/null &&
(
	echo "CES 5.3. OK - Monitoring of sudo commands is enabled."
) ||
(
	echo "CES 5.3. Warning - Enabling monitoring of sudo commands."
	(
	cat << 'EOF'
# 5.3.16 Collect System Administrator Actions (sudolog)
-w /var/log/sudo.log -p wa -k actions

EOF
	) >> /etc/audit/audit.rules
)
# 5.3.17 Collect Kernel Module Loading and Unloading
grep modules /etc/audit/audit.rules > /dev/null &&
(
	echo "CES 5.3.17 OK - Monitoring of Kernel Module load/unload events."
) ||
(
	echo "CES 5.3.17 Warning - Adding monitoring of Kernel Module load/unload events."
	(
	cat << 'EOF'
# 5.3.17 Collect Kernel Module Loading and Unloading
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules
-a always,exit -S init_module -S delete_module -k modules

EOF
	) >> /etc/audit/audit.rules
)

# 5.3.18 Make the Audit Config file Immutable
grep -v "^-e 2$" /etc/audit/audit.rules > /etc/audit/audit.rules.$$ && mv -f /etc/audit/audit.rules.$$ /etc/audit/audit.rules	# Remove the immutable flag
echo -e '-e 2'	>> /etc/audit/audit.rules		# Add immutable flag to EOF

# 5.4 Configure logrotate
sed -i 's/^#compress/compress/g' /etc/logrotate.conf	# Enable log compression by default
(
	cat << 'EOF'
/var/log/boot.log
/var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler
{
    sharedscripts
    postrotate
	/bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
    endscript
}
) > /etc/logrotate.d/syslog


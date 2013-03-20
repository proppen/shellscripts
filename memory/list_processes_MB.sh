#!/bin/bash
#List MB usage for each process in a sorted manner

echo "Counting process usage (megabytes)"
#for p in $(ps -ef|awk '{print $8}'|sort |uniq|sed 's/:$//g'|sed 's/^-//g' | grep -v '\['); do ~/bin/count_proc_memusage.sh "$(basename $p)"; done|sort -n
for p in $(ps -ef|awk '{print $8}'|sort |uniq|sed 's/:$//g'|sed 's/^-//g'); do ~/bin/count_proc_memusage.sh "$(basename $p)"; done|sort -n

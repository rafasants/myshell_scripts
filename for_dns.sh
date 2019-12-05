#!/bin/bash
reset
log="$HOME/log"
list="/usr/local/bin/list"
wc_list=`eval sed -e '1,4d' $list | wc -l`
cat $list | sed -n '1,4p'
for dns in `cat $list| sed '1,4d' $list | awk '{print$3}'| tr -d ")*>"`
        do
                line=`cat $list |grep $dns`
                ping -c3 $dns |grep rtt >/dev/null
                        if [ "$?" -gt "0" ]
                                then
                                        echo -n $line | tr "*" " " && echo "unreachable"
                                else
                                        echo -n $line | tr "*" " " && ping -c3 $dns |grep rtt |awk '{print$4}'| cut -d/ -f1
                        fi
        done
best=`sed -e '1,4d' $log| sed '/unreachable/d' | eval head -$wc_list| awk '{print$5}'| sort -h| head -1`
echo
echo "-------------------------------------------"
echo -n "Best DNS Server: " && eval grep $best $log |awk '{print$1" "($5" ms")}' | tr -d "("
echo "-------------------------------------------"
rm -f $log
exit 0

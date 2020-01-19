#!/bin/bash
# get data createdtime
now=`date -d'-2 minutes' '+%G-%m-%d %H:%M:%S'`
orderTime=$(mysql -h10.35.174.248 -uroot -pnextfintech@2018 tradingcenter -e "select count(*) from tablename where id = 'aaa' and created_at > '${now}';")
echo $orderTime
arr=(${orderTime})
echo ${arr[1]}
if [ ${arr[1]} -gt 0 ];then
echo YES
else
echo NO
fi
# check time with now
#now=`date '+%G-%m-%d %H:%M:%S'`
#echo $ expr '(' $orderTime - $now ')'

#!/bin/bash

HOST="127.0.0.1"
USER="root"
PWD="***"
NOW=`date -d'-1 days' '+%G-%m-%d %H:%M:%S'`
echo $NOW
MYSQL="mysql -h${HOST} -u${USER} -p${PWD} "
ORDER_SQL="use etb_base; select uid, mobilephone  from user where create_time > '${NOW}' ;"
ORDER_COUNT_SQL_SEL="select a.user_id , a.exchange , a.symbol, b.mobilephone, sum(a.volume) s from orders a left join user b on a.user_id = b.uid group by a.exchange, a.symbol order by mobilephone, exchange;"
MSG="[新增用户统计]<br>"
MOBIPHONE_COMP="11111111"

# 查询当日新增用户
USER_ADD_DAY="$($MYSQL -N -e "$ORDER_SQL")"

# 统计数量
USER_ADD_DAY_COUNT=`echo "$USER_ADD_DAY" | wc -l`
MSG=$MSG"Total: "$USER_ADD_DAY_COUNT"<br>"

# 统计手机号
PHONES=`echo "$USER_ADD_DAY" | awk -F" " '{print $2}'`
PHONES_ARR=(${PHONES})
for data in "${PHONES_ARR[@]}"
do
  MSG=$MSG${data}"<br>"
done
MSG=$MSG"<br>"

# 统计实盘交易
MSG=$MSG"<br>[实盘交易用户统计]<br>"
ORDERS_UID_COUNT="$($MYSQL -N -e "$ORDER_COUNT_SQL_SEL")"
OLD_IFS=$IFS
IFS=$'\n'
ARR1=(${ORDERS_UID_COUNT})
IFS=$OLD_IFS
for data in "${ARR1[@]}"
do
  eval $(echo "$data" | awk -F" " '{printf("USERID=%s\nEXCHANGE=%s\nSYMBOL=%s\nMOBIPHONE=%s\nVOLUME=%s",$1,$2,$3,$4,$5)}')
  RESULT=`grep $MOBIPHONE phone`
  if [ -z "$RESULT" ]; then
    if [ $MOBIPHONE_COMP != $MOBIPHONE ]; then
      MSG=$MSG"<br>手机号: ["$MOBIPHONE"]<br>"
      MOBIPHONE_COMP=$MOBIPHONE
    fi
    echo $USERID" "$EXCHANGE" "$SYMBOL" "$MOBIPHONE" "$VOLUME
    MSG=$MSG$EXCHANGE" -- "$SYMBOL" -- "$VOLUME"<br>"
  fi
done

python smtp_count.py "当日新增用户统计" "$MSG"

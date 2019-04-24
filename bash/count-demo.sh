#!/bin/bash
HOST="10.10.10.10"
USER="***"
PWD="***"
NOW=`date -d'-7 days' '+%G-%m-%d %H:%M:%S'`
MYSQL="mysql -h${HOST} -u${USER} -p${PWD} tradingcenter"
ORDER_SQL="use etb_base; select uid, mobilephone  from nft_user where create_time > '${NOW}' ;"
ORDER_COUNT_SQL_SEL="select a.user_id , a.exchange , a.symbol, b.mobilephone, sum(a.volume) s from trd_orders a left join etb_base.nft_user b on a.user_id = b.uid group by a.exchange, a.symbol order by mobilephone, exchange;"
MSG="[新增用户统计]<br>"

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

MSG=$MSG"<br>[实盘交易用户统计]<br>"
# 统计uid
MSG1=$MSG1"手机号: ["$PHONE"]<br>"
ORDERS_UID_COUNT="$($MYSQL -N -e "$ORDER_COUNT_SQL_SEL")"
OLD_IFS=$IFS
IFS=$'\n'
ARR1=(${ORDERS_UID_COUNT})
IFS=$OLD_IFS
for data in "${ARR1[@]}"
do
  eval $(echo "$data" | awk -F" " '{printf("USERID=%s\nEXCHANGE=%s\nSYMBOL=%s\nMOBIPHONE=%s\nVOLUME=%s",$1,$2,$3,$4,$5)}')
  RESULT=`grep $MOBIPHONE phone`
  # 判断结果是否为空  结果为空时  输出数据
  if [ -a "$RESULT" ]; then
    # 如果与上一个mobi不同, 输出当前手机号  否则  不输出手机号 
    # 输出数据
    echo $USERID" "$EXCHANGE" "$SYMBOL" "$MOBIPHONE" "$VOLUME
    # MSG1=$MSG1$EXCHANGE" -- "$SYMBOL" -- "$VOLUME"<br>"
  fi
done

# python /home/tools/smtp_count.py "当日新增用户统计" "$MSG"

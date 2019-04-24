#!/bin/bash

# [ 说明 ] 
# boss 让每天统计一下新增用户, 并且统计一下用户的交易量
# 用 java 就显得没有必要了, 对小功能来说不够灵活
# 这里使用到了 mysql -e 命令, 直接操作数据库, 并使用 shell 命令处理数据
# 最后使用 python 发送短信

HOST="127.0.0.1"
USER="root"
PWD="***"
NOW=`date -d'-1 days' '+%G-%m-%d %H:%M:%S'`
# MYSQL 登录语句
MYSQL="mysql -h${HOST} -u${USER} -p${PWD} "
# SQL 语句
ORDER_SQL="use etb_base; select uid, mobilephone  from user where create_time > '${NOW}' ;"
ORDER_COUNT_SQL_SEL="select a.user_id , a.exchange , a.symbol, b.mobilephone, sum(a.volume) s from orders a left join user b on a.user_id = b.uid group by a.exchange, a.symbol order by mobilephone, exchange;"
MSG="[NEW USER COUNT]<br>"
MOBIPHONE_COMP="11111111"

# 查询当日新增用户
# [ 使用 -N 参数去除结果中的字段名 ]
USER_ADD_DAY="$($MYSQL -N -e "$ORDER_SQL")"

# 统计数量
# [ 直接使用 wc 统计结果数量 ]
USER_ADD_DAY_COUNT=`echo "$USER_ADD_DAY" | wc -l`
MSG=$MSG"Total: "$USER_ADD_DAY_COUNT"<br>"

# [ 使用 awk 输出某些字段 ]
PHONES=`echo "$USER_ADD_DAY" | awk -F" " '{print $2}'`
PHONES_ARR=(${PHONES})
for data in "${PHONES_ARR[@]}"
do
  MSG=$MSG${data}"<br>"
done
MSG=$MSG"<br>"

# 统计某些字段
MSG=$MSG"<br>[TRADING COUNT]<br>"
ORDERS_UID_COUNT="$($MYSQL -N -e "$ORDER_COUNT_SQL_SEL")"
# [ 修改内置分隔符 ]
OLD_IFS=$IFS
IFS=$'\n'
ARR1=(${ORDERS_UID_COUNT})
IFS=$OLD_IFS
for data in "${ARR1[@]}"
do
  # [ awk 对外部变量赋值 ]
  eval $(echo "$data" | awk -F" " '{printf("USERID=%s\nEXCHANGE=%s\nSYMBOL=%s\nMOBIPHONE=%s\nVOLUME=%s",$1,$2,$3,$4,$5)}')
  RESULT=`grep $MOBIPHONE phone`
  # [ 判断 shell 命令结果为空 ]
  if [ -z "$RESULT" ]; then
    if [ $MOBIPHONE_COMP != $MOBIPHONE ]; then
      MSG=$MSG"<br>PHONE: ["$MOBIPHONE"]<br>"
      MOBIPHONE_COMP=$MOBIPHONE
    fi
    echo $USERID" "$EXCHANGE" "$SYMBOL" "$MOBIPHONE" "$VOLUME
    MSG=$MSG$EXCHANGE" -- "$SYMBOL" -- "$VOLUME"<br>"
  fi
done

python smtp_count.py "TITLE" "$MSG"

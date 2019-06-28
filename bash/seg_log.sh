#!/bin/bash

# 获得前一天的日期
NOW=`date -d'-1 days' '+%G%m%d'`
# 设置path
path=$HOME/marsqr/var/log/
# 遍历目录下的文件
files=$(ls $path)
for filename in $files
do
  cp $path/$filename $path/$filename.$NOW
  if [ ! -d "$HOME/bak/var/log/celery" ]; then
    mkdir -p $HOME/bak/var/log/celery
  fi
  mv $path/$filename.$NOW $HOME/bak/var/log/celery/
  echo "" > $path/$filename
done

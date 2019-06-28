#!/bin/bash
  
NOW=`date -d'-1 days' '+%G%m%d'`

path=$HOME/marsqr/var/log/
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

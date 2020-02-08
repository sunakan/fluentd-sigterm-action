#!/bin/bash

set -eu

trap catch ERR
trap finally EXIT
function catch {
  echo "ERRORを検知しました"
}
function finally {
  echo "COUNT = $(expr $count - 1)まではlogを飛ばしました"
  echo "Fluentdのoutputに"
  echo "COUNT = $(expr $count - 1)がなければその分logが消失しています"
}


time=$(date --date='2020-01-01 15:00:00' +%s)
count=0

while :
do
  time=$(expr $time + 60)
  count=$(expr $count + 1)
  echo "{\"count\":${count},\"unix_time\":${time}}" | fluent-cat --host fluentd debug.log
  sleep 0.1s
done

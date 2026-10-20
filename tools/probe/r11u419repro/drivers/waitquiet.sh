#!/bin/bash
# r11u419 waitquiet.sh: block until three consecutive quiet readings 20 s apart (max 2 h), print the wait
H=$(dirname $(readlink -f $0)); n=0; t=0
while [ $n -lt 3 ] && [ $t -lt 7200 ]; do
  if [ "$(bash $H/quiet.sh)" = 0 ]; then n=$((n+1)); else n=0; fi
  [ $n -lt 3 ] && sleep 20; t=$((t+20))
done
echo "quiet after ${t}s (readings=$n)"

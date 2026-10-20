#!/bin/bash
# wait until three consecutive quiet readings (no sweep/runner of anyone), max $1 seconds
end=$(( $(date +%s) + ${1:-14400} ))
while [ $(date +%s) -lt $end ]; do
  if /tmp/r11u421_bin/quiet.sh >/dev/null; then echo QUIET; exit 0; fi
  sleep 30
done
echo TIMEOUT; exit 1

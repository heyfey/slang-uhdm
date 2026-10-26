#!/bin/bash
# three consecutive quiet readings: a live sweep driver or harness process
# (matched on the program actually running, not on shell text)
q=0
while [ $q -lt 3 ]; do
  n=$(ps -eo args | grep -E '^(bash|/bin/bash) [^ ]*tests/swee[p]\.sh|^[^ ]*python3? [^ ]*(verify_golde[n]|check_prob[e]|downstream_uhdm2rtli[l]|check_svtest[s]|svtests_matri[x])' | wc -l)
  if [ "$n" -gt 0 ]; then q=0; else q=$((q+1)); fi
  sleep 20
done
date

#!/bin/bash
# quiet3.sh: wait for three consecutive quiet readings (no sweep / runner of any pass)
n=0
while [ $n -lt 3 ]; do
  c=$(ps -eo pid,args | grep -E 'python3 [^ ]*(verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests|svtests_matrix)\.py|bash [^ ]*tests/sweep\.sh' | grep -v grep | wc -l)
  if [ "$c" = 0 ]; then n=$((n+1)); else n=0; fi
  sleep 30
done
echo "quiet $(date +%T)"

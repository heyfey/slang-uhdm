#!/bin/bash
# quiet.sh: wait until no sweep / runner process of any pass is live (self excluded by pattern anchoring on python3/bash tests/sweep.sh)
while true; do
  n=$(ps -eo pid,args | grep -E 'python3 [^ ]*(verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests|svtests_matrix)\.py|bash [^ ]*tests/sweep\.sh' | grep -v grep | wc -l)
  [ "$n" = 0 ] && break
  sleep 30
done
date

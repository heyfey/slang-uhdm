#!/bin/bash
# wait until no sweep/runner process (excluding this script and pgrep) for 3 consecutive readings 60s apart
n=0
while [ $n -lt 3 ]; do
  l=$(pgrep -af 'sweep.sh|svtests_matrix|verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests' | grep -v 'pgrep\|waitquiet\|bash -c' )
  if [ -z "$l" ]; then n=$((n+1)); else n=0; fi
  sleep 60
done
date; echo QUIET3

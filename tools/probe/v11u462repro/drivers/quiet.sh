#!/bin/bash
# wait until no sweep / runner is live for 3 consecutive readings 20 s apart
n=0
while [ $n -lt 3 ]; do
  if pgrep -af 'sweep\.sh|svtests_matrix|verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests' | grep -v quiet.sh >/dev/null; then n=0; else n=$((n+1)); fi
  sleep 20
done
date; echo QUIET

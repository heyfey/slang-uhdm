#!/bin/bash
# wait until no sweep/runner process is live (3 consecutive quiet readings 20 s apart);
# shell wrappers (bash -c ...) are excluded so a waiter never matches itself
q=0
while [ $q -lt 3 ]; do
  if pgrep -af 'tests/sweep.sh|svtests_matrix.py|verify_golden.py|check_probe.py|downstream_uhdm2rtlil.py|check_svtests.py' | grep -v -e 'bash -c' -e 'v11u452_quiet' | grep -q .; then q=0; else q=$((q+1)); fi
  sleep 20
done

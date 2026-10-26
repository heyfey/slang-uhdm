#!/bin/bash
# quiet3.sh: wait for three consecutive quiet readings (60 s apart) with no sweep/runner process of any pass
pat='^(/usr/bin/)?(python3?|bash|/bin/bash|sh) +([^ ]*/)?(tests/sweep\.sh|scripts/svtests/svtests_matrix\.py|scripts/verify_golden\.py|scripts/check_probe\.py|scripts/downstream_uhdm2rtlil\.py|scripts/check_svtests\.py)'
n=0; while [ $n -lt 3 ]; do if pgrep -f "$pat" >/dev/null; then n=0; else n=$((n+1)); fi; sleep 60; done
echo quiet $(date +%T)

#!/bin/bash
# wait for three consecutive quiet readings 20 s apart; any sweep/runner process or another pass's
# fullsweep driver counts as busy, this pass's own drivers (v11u436) do not
P='^(/usr/bin/)?(python3?|bash|/bin/bash|sh) +([^ ]*/)?(tests/sweep\.sh|scripts/svtests/svtests_matrix\.py|scripts/verify_golden\.py|scripts/check_probe\.py|scripts/downstream_uhdm2rtlil\.py|scripts/check_svtests\.py|[^ ]*fullsweep\.sh)'
busy() { pgrep -af "$P" | grep -v '/tmp/v11u436_scr/' | grep -q .; }
n=0; while [ $n -lt 3 ]; do if busy; then n=0; else n=$((n+1)); fi; sleep 20; done; echo "quiet3 $(date)"

#!/bin/bash
# quiet.sh: wait until no sweep/runner process of any pass is live for three readings 20 s apart;
# anchored on the interpreter (any path) so a shell wrapper quoting the names does not match
pat='^([^ ]*/)?(python3?|bash|sh) +([^ ]*/)?(tests/sweep\.sh|scripts/svtests/svtests_matrix\.py|scripts/verify_golden\.py|scripts/check_probe\.py|scripts/downstream_uhdm2rtlil\.py|scripts/check_svtests\.py)'
n=0
while [ $n -lt 3 ]; do
  if pgrep -f "$pat" >/dev/null; then n=0; else n=$((n+1)); fi
  sleep 20
done
echo quiet $(date)

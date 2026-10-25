#!/bin/bash
# quiet.sh: wait until no sweep/runner process of any pass is live; anchored on the interpreter so a shell wrapper quoting the names does not match
while pgrep -f '^(/usr/bin/)?(python3?|bash|/bin/bash|sh) +([^ ]*/)?(tests/sweep\.sh|scripts/svtests/svtests_matrix\.py|scripts/verify_golden\.py|scripts/check_probe\.py|scripts/downstream_uhdm2rtlil\.py|scripts/check_svtests\.py)' >/dev/null; do sleep 20; done
echo quiet $(date)

#!/bin/bash
# quiet3.sh: wait for three consecutive quiet readings (no sweep, runner, probe, verify, downstream or sv-tests process), 20 s apart
q() { [ -z "$(pgrep -f '^(/usr/bin/)?python3 [^ ]*(svtests_matrix|check_probe|verify_golden|downstream_uhdm2rtlil|check_svtests)\.py|^(/bin/)?bash [^ ]*tests/sweep\.sh')" ]; }
n=0; while [ $n -lt 3 ]; do if q; then n=$((n+1)); else n=0; echo "busy $(date +%T)"; fi; sleep 20; done; echo "quiet $(date +%T)"

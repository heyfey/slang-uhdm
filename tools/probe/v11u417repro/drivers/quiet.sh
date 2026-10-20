#!/bin/bash
# wait until three consecutive reads find no sweep/runner process
n=0; while [ $n -lt 3 ]; do if pgrep -f 'sweep.sh|svtests_matrix|verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests' | grep -vx "$$" | xargs -r ps -o cmd= -p 2>/dev/null | grep -v 'pgrep\|while pgrep\|quiet.sh' | grep -q .; then n=0; else n=$((n+1)); fi; sleep 20; done; date

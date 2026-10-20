#!/bin/bash
# three quiet readings 5 s apart; exit 1 if any sweep/runner is live
for i in 1 2 3; do n=$(pgrep -af 'sweep.sh|svtests_matrix|verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests' | grep -v 'pgrep\|quiet.sh' | wc -l); [ $n -eq 0 ] || { echo BUSY $n; exit 1; }; sleep 5; done; echo QUIET

#!/bin/bash
# prints the count of live sweep/runner processes, skipping this script and its parent shell
pgrep -f 'sweep\.sh|svtests_matrix|verify_golden|check_probe|downstream_uhdm2rtlil|check_svtests' | grep -vxE "$$|$PPID" | wc -l

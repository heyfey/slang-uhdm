#!/bin/bash
# wait until 3 consecutive readings (20 s apart) show no sweep/runner process other than this script's ancestors
anc=" "; p=$$; while [ "$p" -gt 1 ]; do anc="$anc$p "; p=$(awk '{print $4}' /proc/$p/stat 2>/dev/null || echo 1); done
q=0; while [ $q -lt 3 ]; do n=0; for x in $(pgrep -f 'tests/sweep\.sh|svtests_matrix\.py|verify_golden\.py|check_probe\.py|downstream_uhdm2rtlil\.py|check_svtests\.py'); do case "$anc" in *" $x "*) ;; *) n=$((n+1));; esac; done; if [ $n -gt 0 ]; then q=0; else q=$((q+1)); fi; sleep 20; done; date

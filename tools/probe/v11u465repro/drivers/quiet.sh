#!/bin/bash
# prints the count of live sweep/runner processes, excluding this script's ancestry
ps -eo pid,ppid,args | awk -v me=$$ -v pp=$PPID '$1!=me && $1!=pp && ($3 ~ /python3|bash/) && ($0 ~ /tests\/sweep\.sh|verify_golden\.py|check_probe\.py|downstream_uhdm2rtlil\.py|check_svtests\.py|svtests_matrix\.py/) && ($0 !~ /quiet\.sh/)' | wc -l

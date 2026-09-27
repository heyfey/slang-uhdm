#!/bin/bash
# parents.sh <uhdm> <regex of the typespec header> : the vpiParent of every listing object whose header matches
. /tmp/wt_r11u180/tools/probe/r11u180repro/drivers/env.sh || exit 2
$UHDM_DUMP $1 2>/dev/null | grep -A3 -E "$2" | grep -A1 vpiParent | grep -v 'vpiParent\|^--' | sed 's/, file.*//' | sort | uniq -c

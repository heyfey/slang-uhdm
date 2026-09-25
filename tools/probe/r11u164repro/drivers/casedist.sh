#!/bin/bash
# casedist.sh <case rel under $GW> <tagA> <tagB>: order-blind uhdm-dump distance (sorted dump lines of golden not
# matched in ours plus ours not in golden, file paths reduced to basenames) for two exports of a case run by case.sh.
GW=${GW:-/tmp/r11u164_g}; w=$GW/$1
norm() { $UHDM_DUMP $1 2>/dev/null | sed 1d | sed -E 's#(file:)[^,]*/#\1#' | sort; }
norm $w/gold/golden.uhdm > $w/g.sorted
for t in $2 $3; do norm $w/$t.uhdm > $w/$t.sorted; echo -n "$t=$(comm -3 $w/g.sorted $w/$t.sorted | wc -l) "; done; echo

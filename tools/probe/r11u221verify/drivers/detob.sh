#!/bin/bash
# (r11u217) detob.sh <a.uhdm> <b.uhdm> <label>: for two draws of one row-mode: the ordered uhdm-dump difference (lines,
# the file-name line dropped) and the order-blind difference (sorted dumps).  Used on the determinism draws of the six
# unfenced rows only (the caller names them).
source "$(dirname "$0")/env.sh" || exit 2
T=/tmp/r11u221_detob; mkdir -p $T
$UHDM_DUMP $1 2>/dev/null | tail -n +2 > $T/a; $UHDM_DUMP $2 2>/dev/null | tail -n +2 > $T/b
o=$(diff $T/a $T/b | grep -c '^[<>]'); LC_ALL=C sort $T/a > $T/as; LC_ALL=C sort $T/b > $T/bs; s=$(LC_ALL=C comm -3 $T/as $T/bs | wc -l)
echo "$3 $(md5sum < $1 | cut -c1-12)/$(md5sum < $2 | cut -c1-12) ordered_lines=$o orderblind_lines=$s"

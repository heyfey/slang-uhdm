#!/bin/bash
# r11u31 — order-blind whole-dump diff for one verify_golden row.
# usage: fulldiff.sh <workdir> <mode> <test>
set -u
WD=${1:?}; MODE=${2:?}; T=${3:?}
D=$(ls -d "$WD/$MODE/$T"-*/ 2>/dev/null | head -1)
[ -n "$D" ] || { echo "NO-DIR $T/$MODE"; exit 3; }
G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$D/cmds.txt" | head -1)/golden.uhdm
O="$D/slang.uhdm"
[ -f "$G" ] || { echo "NO-GOLDEN $T/$MODE"; exit 3; }
[ -f "$O" ] || { echo "NO-OURS $T/$MODE"; exit 3; }
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
norm() { sed -e "s#$D##g" -e 's#/home/heyfey/[^ ,)]*##g' -e 's/, id:[0-9]*//g'; }
"$DUMP" "$G" 2>&1 | norm | sort > /tmp/r11u31_fd_g.$$
"$DUMP" "$O" 2>&1 | norm | sort > /tmp/r11u31_fd_o.$$
echo "== $T/$MODE  order-blind dump diff (< golden, > ours)"
diff /tmp/r11u31_fd_g.$$ /tmp/r11u31_fd_o.$$ | head -${HEADN:-200}
echo "-- difflines=$(diff /tmp/r11u31_fd_g.$$ /tmp/r11u31_fd_o.$$ | grep -c '^[<>]'; true)"
rm -f /tmp/r11u31_fd_g.$$ /tmp/r11u31_fd_o.$$

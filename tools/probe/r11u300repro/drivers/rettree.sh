#!/bin/bash
# r11u300 rettree.sh <case dir> <binary> [d|e]: the golden's and ours' TOP package listings side by side
# (retids, built by `bash cc_retids.sh`).  Fail-closed on $FENCED (env.sh, case.sh).
H=$(cd "$(dirname "$0")" && pwd); source "$H/env.sh" || exit 2
d=$(realpath "$1"); b=$2; v=${3:-d}
for n in $FENCED; do echo "$d" | grep -qw "$n" && { echo "rettree: fenced path refused" >&2; exit 2; }; done
R=${RETIDS:-/tmp/r11u300_bin/retids}; [ -x "$R" ] || { echo "rettree: retids not built" >&2; exit 2; }
k=/tmp/r11u300_scr/rt.$$.uhdm; rm -f $k
r=$(KEEP=$k bash "$H/case.sh" "$d" "$b" $v 3); echo "$r" | head -1
h=$( (cd $d && find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$v
G=${R300_GOLD:-/tmp/r11u300_gold}
echo "--- golden"; $R $G/$h/g.uhdm | sed -n "/^${SECT:-TOP}/,\$p"
echo "--- ours"; [ -s $k ] && $R $k | sed -n "/^${SECT:-TOP}/,\$p"; rm -f $k

#!/bin/bash
# obd.sh <case dir> <label...>: order-blind dump distance of each label's ours.uhdm vs golden (ids and paths stripped)
. "$(dirname "$(realpath "$0")")"/env.sh
c=$1; shift; k=$(echo "$c" | md5sum | cut -c1-10)
norm(){ "$UHDM_DUMP" "$1" 2>/dev/null | sed -E 's/, id:[0-9]+//g; s#file:[^,]*/##g; s#/tmp/v11u195_gold/[^ ,]*##g' | sort; }
G=$(cat /tmp/v11u195_judge/$1/$k/golden.path)/golden.uhdm; norm $G > /tmp/v11u195_obd_g.$$
out="$(echo $c | sed 's#.*/cases/##')"
for l in "$@"; do norm /tmp/v11u195_judge/$l/$k/ours.uhdm > /tmp/v11u195_obd_o.$$; n=$(diff /tmp/v11u195_obd_g.$$ /tmp/v11u195_obd_o.$$ | grep -c '^[<>]'); out="$out $l=$n"; done
rm -f /tmp/v11u195_obd_*.$$; echo "$out"

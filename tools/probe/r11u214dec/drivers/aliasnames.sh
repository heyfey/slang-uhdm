#!/bin/bash
# aliasnames.sh <casedir> <tag> [EL] — after case.sh: the raw full name of every ref_typespec record whose canonical
# full name ends in the pattern $PAT (default ALIAS_T), golden and ours side by side (strictcmp_x record dumps, the
# 15th column's raw full name). Fail-closed on $FENCED via case.sh's key.
[ -n "$FENCED" ] && [ -n "$S" ] || { echo "aliasnames.sh: source drivers/env.sh" >&2; exit 2; }
c=$(realpath $1); t=$2; ek=""; [ "${3:-0}" = 1 ] && ek="_el"
for n in $FENCED; do echo "$c" | grep -qw "$n" && exit 2; done
rel=$(echo $c | sed "s#.*/r11u214dec/cases/##; s#.*/tests/probe/#probe/#; s#.*/tools/probe/#tp/#")
w=$S/g/$rel$ek; g=$(ls $w/gold_*/golden.uhdm 2>/dev/null | head -1); [ -s "$g" ] || exit 0
$B/strictcmp_x --max 0 --dump-a $w/$t.xa --dump-b $w/$t.xb $g $w/$t.uhdm > /dev/null 2>&1
P=${PAT:-ALIAS_T}
for s in a b; do
  awk -F'\t' -v P="$P" -v S=$s '$2=="ref_typespec" && $5 ~ P {split($15,x,"\x1f"); print S"\t"x[1]}' $w/$t.x$s | sort | uniq -c | sed "s#^#$rel$ek #"
done

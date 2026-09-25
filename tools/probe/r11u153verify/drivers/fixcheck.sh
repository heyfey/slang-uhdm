#!/bin/bash
# fixcheck.sh <out.tsv> <casedir>...: per case, the landed binary (pris.bin = d10675dd) against the refined
# binary (fix.bin), each judged against golden (case.sh), plus fix.bin under R11U153_OFF=1 (must equal the
# landed bytes). Columns: case, landed verdict, fix verdict, fix==landed bytes?, R11U153_OFF==landed bytes?
. /tmp/r11u153_env.sh
D=$(dirname $(realpath $0)); OUT=$1; shift
export GW=/tmp/r11u153_gF
printf 'case\tlanded\tfix\tfix_moves\tmaster_off_is_landed\n' > $OUT
for c in "$@"; do
  L=$($D/case.sh $c /tmp/r11u153_bin/pris.bin L); F=$($D/case.sh $c /tmp/r11u153_bin/fix.bin F); M=$($D/case.sh $c /tmp/r11u153_bin/fix.bin M R11U153_OFF=1)
  ml=$(echo "$L" | grep -o 'md5=[0-9a-f]*'); mf=$(echo "$F" | grep -o 'md5=[0-9a-f]*'); mm=$(echo "$M" | grep -o 'md5=[0-9a-f]*')
  v(){ echo "$1" | sed 's/.* rc=/rc=/; s/ md5=.*//'; }
  printf '%s\t%s\t%s\t%s\t%s\n' "$(echo $L | cut -d' ' -f1)" "$(v "$L")" "$(v "$F")" $([ "$ml" = "$mf" ] && echo same || echo MOVES) $([ "$ml" = "$mm" ] && echo yes || echo NO) >> $OUT
done

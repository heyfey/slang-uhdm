#!/bin/bash
# r11u183: pin OUR record #N (strict walk order, 1-based line of the b-dump) of a case to its mint.
# usage: pinrec.sh <case dir> <record line in ours' dump>   (runs case.sh's outputs from $OUT or re-exports)
set -u; D=$(cd "$1" && pwd); N=$2; T=/tmp/r11u183_pinrec_$$; mkdir -p $T
( cd "$D" && /tmp/r11u183_bin/slang-uhdm dut.sv --single-unit --nobuiltin -o $T/o.uhdm >/dev/null 2>&1 )
K=$(cat "$D"/*.sv | md5sum | cut -c1-16); G=/tmp/r11u183_gold/$K/golden.uhdm
/tmp/r11u183_bin/strictcmp_x --max 0 --dump-ids --dump-a $T/a --dump-b $T/b "$G" $T/o.uhdm >/dev/null 2>&1
rec=$(sed -n "${N}p" $T/b); ty=$(echo "$rec" | cut -f2); id=$(echo "$rec" | cut -f15 | awk -F'\037' '{print $NF}')
rank=$(/tmp/r11u183_objrank $T/o.uhdm | awk -F'\t' -v t="$ty" -v i="$id" '$1==t && $3==i {print $2}')
Ty=$(echo "$ty" | sed -E 's/^(.)/\U\1/')
echo "record $N: $(echo "$rec" | cut -f1-10 | tr '\t' ' ') id=$id rank=$rank Make$Ty"
$(dirname "$0")/pin.sh "$D" "$Ty" "$rank"; rm -rf $T

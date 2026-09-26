#!/bin/bash
# offbytes.sh <lawbin> <out.tsv> <ENV=VAL|-> <casedir>...: export every case (dut.sv --single-unit --nobuiltin) with the
# pristine binary and with <lawbin> under the given environment, compare the databases byte for byte.
# prints per case: <case> SAME|MOVER|NODB.  Refuses a fenced path (FENCED from drivers/env.sh, fail closed).
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "offbytes.sh: export FENCED first" >&2; exit 1; }
L=$1; O=$2; E=$3; shift 3; P=/tmp/r11u174_bin/pris; W=/tmp/r11u174_ob; mkdir -p $W; : > $O
fre=$(echo $FENCED | sed 's/ /|/g')
for c in "$@"; do
  echo "$c" | grep -Eqw "$fre" && { echo "fenced path refused" >&2; continue; }
  k=$(echo $c | md5sum | cut -c1-12); rm -f $W/$k.p $W/$k.l
  (cd $c && $P dut.sv --single-unit --nobuiltin -o $W/$k.p >/dev/null 2>&1 </dev/null)
  if [ "$E" = - ]; then (cd $c && $L dut.sv --single-unit --nobuiltin -o $W/$k.l >/dev/null 2>&1 </dev/null)
  else (cd $c && env $E $L dut.sv --single-unit --nobuiltin -o $W/$k.l >/dev/null 2>&1 </dev/null); fi
  if [ ! -s $W/$k.p ] && [ ! -s $W/$k.l ]; then v=NODB; elif cmp -s $W/$k.p $W/$k.l; then v=SAME; else v=MOVER; fi
  echo -e "$c\t$v" >> $O
done
awk -F'\t' '{n[$2]++} END{for (k in n) printf "%s=%d ", k, n[k]; print ""}' $O

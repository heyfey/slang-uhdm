#!/bin/bash
# r11u222map: probe databases of two sweeps run from DIFFERENT checkouts embed the case path, so their bytes always
# differ; this compares them by uhdm-dump with each side's checkout path replaced by REPO (and the database path by
# DB).   usage: probecmp.sh <sweep A> <checkout A> <sweep B> <checkout B> <out>     (prints MOVERS n / total)
. "$(dirname "$0")/env.sh"
[ -x "$UHDM_DUMP" ] || { echo "probecmp: UHDM_DUMP not executable" >&2; exit 2; }
A=$1; RA=$2; Bw=$3; RB=$4; O=$5; : > $O
one() {
  b=$(basename $1)
  x=$($UHDM_DUMP $1 2>/dev/null | sed "s#$2#REPO#g; s#$1#DB#g" | md5sum | cut -c1-12)
  y=$($UHDM_DUMP $3/probe/$b 2>/dev/null | sed "s#$4#REPO#g; s#$3/probe/$b#DB#g" | md5sum | cut -c1-12)
  [ "$x" = "$y" ] || echo "PMOVER $b $x $y"
}
export -f one; export UHDM_DUMP
ls $A/probe/*.uhdm | xargs -P3 -I{} bash -c "one {} $RA $Bw $RB" >> $O
echo "MOVERS: $(grep -c PMOVER $O) / $(ls $A/probe/*.uhdm | wc -l)"

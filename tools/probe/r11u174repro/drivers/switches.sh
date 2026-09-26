#!/bin/bash
# switches.sh <lawbin> <casedir>...: per case, the pristine bytes, the law bytes, and the law bytes with each switch set alone;
# prints <case> law=<SAME|MOVER vs pristine> then, per switch, 'acts' when setting it changes the law bytes and '=pris'
# when that alone restores the pristine bytes; ALL = R11U174_OFF.  Refuses a fenced path (fail closed).
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "switches.sh: export FENCED first" >&2; exit 1; }
L=$1; shift; P=/tmp/r11u174_bin/pris; W=/tmp/r11u174_sw; mkdir -p $W
fre=$(echo $FENCED | sed 's/ /|/g')
SW="R11U172_DEPTH_OFF R11U174_LEFTREF_OFF R11U174_ASMSPAN_OFF R11U174_MOPUNLOC_OFF R11U174_OFF"
for c in "$@"; do
  echo "$c" | grep -Eqw "$fre" && { echo "fenced path refused" >&2; continue; }
  k=$(echo $c | md5sum | cut -c1-12); rm -f $W/$k.*
  (cd $c && $P dut.sv --single-unit --nobuiltin -o $W/$k.p >/dev/null 2>&1 </dev/null)
  (cd $c && $L dut.sv --single-unit --nobuiltin -o $W/$k.l >/dev/null 2>&1 </dev/null)
  cmp -s $W/$k.p $W/$k.l && lv=SAME || lv=MOVER
  line="$(echo $c | sed 's#.*/tools/probe/##') law=$lv"
  for s in $SW; do
    (cd $c && env $s=1 $L dut.sv --single-unit --nobuiltin -o $W/$k.s >/dev/null 2>&1 </dev/null)
    a=""; cmp -s $W/$k.s $W/$k.l || a="acts"; cmp -s $W/$k.s $W/$k.p && a="$a=pris"
    line="$line ${s%_OFF}:${a:-nop}"; rm -f $W/$k.s
  done
  echo "$line"
done

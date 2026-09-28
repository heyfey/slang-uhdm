#!/bin/bash
# (r11u208: copied from r11u204verify/drivers, paths renamed; the refinement under test is r11u208's § opCtxTargetAncestorBind208v.)
# (r11u204: adapted from r11u199verify/drivers/fixbound.sh; the refinements under test are r11u204's five.)
# fixbound.sh <out> <dir>...: the fix's case boundary.  For every case dir (a dut.sv) under the given tools/probe dirs,
# both views (default; --elabuhdm): md5 of law.bin (HEAD), fix.bin, fix.bin with R11V208_OFF=1 (must equal law.bin),
# and each refinement switch alone on fix.bin.  One line per case-mode: SAME / MOVED (fix vs law), off_all, and per
# switch whether it restores law's bytes (law), keeps fix's (fix) or neither (other).  Three cases at a time.
# Refuses fenced paths (fail-closed on $FENCED).
source "$(dirname "$0")/env.sh" || exit 2
O=$1; shift; : > $O.parts; T=/tmp/r11u208_fb; mkdir -p $T
one() {
  c=$1; k=$(echo $c | md5sum | cut -c1-12)
  echo "$c" | grep -Pq "$FENCE_RE" && { echo "FENCED-SKIP"; return; }
  [ -f $c/dut.sv ] || return
  SRC=dut.sv; [ -f $c/args ] && SRC=$(cat $c/args)
  for el in "" "--elabuhdm"; do
    h(){ rm -f $T/$k.uhdm; (cd $c && env "$@" $SRC --single-unit --nobuiltin $el -o $T/$k.uhdm > /dev/null 2>&1); md5sum < $T/$k.uhdm 2>/dev/null | cut -c1-10; }
    a=$(h $LAW); b=$(h $FIX); z=$(h R11V208_OFF=1 $FIX)
    line="${c#$R208_ROOT/tools/probe/}${el:+ el} $([ "$a" != "$b" ] && echo MOVED || echo SAME) off_all=$([ "$z" = "$a" ] && echo law || echo DIFF)"
    for sw in OPTGTANC; do
      s=$(h R11V208_${sw}_OFF=1 $FIX)
      line="$line ${sw}_OFF=$([ "$s" = "$b" ] && echo fix || ([ "$s" = "$a" ] && echo law || echo other))"
    done
    echo "$line"
  done
  rm -f $T/$k.uhdm
}
export -f one; export T
for d in "$@"; do find $R208_ROOT/tools/probe/$d -name dut.sv -printf '%h\n'; done | sort -u | grep -vP "$FENCE_RE" | xargs -P 3 -I{} bash -c 'one {}' >> $O.parts
sort $O.parts > $O; rm -f $O.parts; echo "FIXBOUND_DONE lines=$(wc -l < $O)" >> $O

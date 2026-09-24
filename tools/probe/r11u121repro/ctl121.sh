#!/usr/bin/env bash
# r11u121 boundary: compile every dut.sv under tools/probe (+ tests/probe) with two binaries,
# both forms (probe flags; downstream -DSYNTHESIS), and compare rc + database md5 per arm-form.
# usage: [FENCED=<regex of paths to skip>] ctl121.sh <repo> <binA> <binB> <out.txt> [jobs]
# (no arm under tools/probe or tests/probe is a slang-fenced corpus test)
set -u
R=$1; A=$2; B=$3; OUT=$4; J=${5:-3}
S=/tmp/r11u121_ctl_scratch; mkdir -p $S
one() {
  local rel=$1 d=$R/$1 f k o r1 r2 m1 m2
  for f in pr ds; do
    k=$(echo "$rel/$f" | md5sum | cut -c1-16)
    for b in A B; do
      o=$S/$k.$b.uhdm; rm -f $o
      if [ $b = A ]; then bin=$BA; else bin=$BB; fi
      if [ $f = ds ]; then (cd $d && timeout 120 $bin -DSYNTHESIS dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1 </dev/null); else (cd $d && timeout 120 $bin dut.sv --single-unit --nobuiltin -o $o >/dev/null 2>&1 </dev/null); fi
      r=$?; m=$(md5sum < $o 2>/dev/null | cut -c1-12); rm -f $o
      if [ $b = A ]; then r1=$r; m1=$m; else r2=$r; m2=$m; fi
    done
    if [ "$r1/$m1" = "$r2/$m2" ]; then echo "SAME $rel $f rc=$r1"; else echo "DIFF $rel $f rc=$r1/$r2"; fi
  done
}
export -f one; export R S; export BA=$A BB=$B
(cd $R && find tools/probe tests/probe -name dut.sv -printf '%h\n' | grep -v 'r11u121repro' | { if [ -n "${FENCED:-}" ]; then grep -Ev "$FENCED"; else cat; fi; } | sort -u) > $OUT.list
exec 3< $OUT.list
xargs -P $J -I{} bash -c 'one "$@" </dev/null' _ {} <&3 > $OUT.raw
sort $OUT.raw > $OUT
echo "LISTED=$(wc -l < $OUT.list) PROCESSED_FORMS=$(wc -l < $OUT) SAME=$(grep -c ^SAME $OUT) DIFF=$(grep -c ^DIFF $OUT)"

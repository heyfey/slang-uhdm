#!/bin/bash
# oldbytes.sh <casedir>: an earlier pass's case run in place (never copied) with the HEAD binary and the fix
# binary (and --elabuhdm); prints SAME / MOVED per mode.  Fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "oldbytes.sh: source drivers/env.sh" >&2; exit 2; }
c=$(realpath $1); for n in $FENCED; do echo "$c" | grep -qw "$n" && { echo "FENCED-SKIP"; exit 0; }; done
k=$(echo $c | sed 's#.*/tools/probe/##; s#/#__#g'); t=/tmp/r11u170_ob/$k; mkdir -p $t; r=""
for m in "" --elabuhdm; do
  rm -f $t/h.uhdm $t/f.uhdm
  (cd $c && timeout 120 $LAW dut.sv --single-unit --nobuiltin $m -o $t/h.uhdm > /dev/null 2>&1; timeout 120 $FIX dut.sv --single-unit --nobuiltin $m -o $t/f.uhdm > /dev/null 2>&1)
  if [ ! -s $t/h.uhdm ] && [ ! -s $t/f.uhdm ]; then r="$r ${m:-def}:NODB"; elif cmp -s $t/h.uhdm $t/f.uhdm; then r="$r ${m:-def}:SAME"; else r="$r ${m:-def}:MOVED"; cp $t/h.uhdm $t/h$m.uhdm; cp $t/f.uhdm $t/f$m.uhdm; fi
done
echo "${c#*/tools/probe/}$r"

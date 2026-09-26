#!/bin/bash
# fixbytes.sh <out> <case root>...: every case (a dir holding dut.sv or dut.v; an `args` file lists its root files)
# under the given roots, exported by law.bin (50a01bc3) and the fix binary ($FIXBIN, default fix4.bin = law + fix.patch) with check_probe's arguments;
# prints one line per case (rc and md5 of each) and the byte movers.  Cases are read from a list on fd 3 (children
# get </dev/null); scratch keyed on the relative path.  A path holding a fenced name is refused (fail-closed).
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "fixbytes.sh: source drivers/env.sh (FENCED)" >&2; exit 2; }
O=$1; shift; S=/tmp/r11u177_fixbytes; mkdir -p $S
find "$@" \( -name dut.sv -o -name dut.v \) -printf '%h\n' | sort -u > $O.list
n=0; mv=0; : > $O
exec 3< $O.list
while read -r d <&3; do
  for f in $FENCED; do echo "$d" | grep -qw "$f" && { echo "FENCED-REFUSED $d" >> $O; continue 2; }; done
  k=$(echo $d | sed 's#.*/tools/probe/##; s#/#__#g'); src=dut.sv; [ -f $d/dut.sv ] || src=dut.v; [ -f $d/args ] && src=$(cat $d/args)
  line="$(echo $d | sed 's#.*/tools/probe/##')"
  for t in L F; do b=/tmp/r11u177_bin/law.bin; [ $t = F ] && b=${FIXBIN:-/tmp/r11u177_bin/fix4.bin}
    rm -f $S/$k.$t.uhdm; (cd $d && timeout 300 $b $src --single-unit --nobuiltin -o $S/$k.$t.uhdm </dev/null >/dev/null 2>&1); rc=$?
    line="$line $t:$rc:$( [ -s $S/$k.$t.uhdm ] && md5sum < $S/$k.$t.uhdm | cut -c1-10 || echo none)"; done
  n=$((n+1)); a=$(echo $line | awk '{print $2}' | cut -d: -f3); b=$(echo $line | awk '{print $3}' | cut -d: -f3)
  [ "$a" != "$b" ] && { mv=$((mv+1)); line="$line MOVER"; }
  echo "$line" >> $O
done
echo "cases $n listed $(wc -l < $O.list) movers $mv" | tee -a $O

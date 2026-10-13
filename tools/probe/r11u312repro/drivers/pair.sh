#!/bin/bash
# r11u312 pair.sh <case dir> <binary> [d|e]: golden (from case.sh's cache, built on a miss) and ours dumped side
# by side into $R312_PAIR (default /tmp/r11u312_pair/<case>_<view>.{g,o}.txt) for decoding.  Fail-closed on $FENCED.
H=$(cd "$(dirname "$0")" && pwd)
source "$H/env.sh" || exit 2
d=$(realpath "$1"); bin=$2; v=${3:-d}
[ -x "$bin" ] && [ -x "$UHDM_DUMP" ] || { echo "pair.sh: binary or UHDM_DUMP not executable" >&2; exit 2; }
for n in $FENCED; do echo "$d" | grep -qw "$n" && { echo "pair.sh: fenced path refused" >&2; exit 2; }; done
bash "$H/case.sh" "$d" "$bin" $v >/dev/null
G=${R312_GOLD:-/tmp/r11u312_gold}
h=$( (cd $d && find . -maxdepth 1 -type f \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) | sort | xargs cat) | md5sum | cut -c1-16)$v
P=${R312_PAIR:-/tmp/r11u312_pair}; mkdir -p $P; b=$P/$(basename $d)_$v
o=$b.uhdm; rm -f $o
ex=""; [ $v = e ] && ex="--elabuhdm"
(cd $d && $bin dut.sv --single-unit --nobuiltin $ex -o $o >/dev/null 2>&1 </dev/null)
"$UHDM_DUMP" $G/$h/g.uhdm 2>/dev/null | sed "s#$d/##g" > $b.g.txt
"$UHDM_DUMP" $o 2>/dev/null | sed "s#$d/##g" > $b.o.txt
echo $b.g.txt $b.o.txt

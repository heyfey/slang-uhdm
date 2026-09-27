#!/bin/bash
# r11u183: the whole-pass switch restores pristine bytes.  For every case dir (tests/probe + this pass's cases),
# run the pristine binary and the law binary under R11U183_OFF=1 with check_probe's arguments; print SAME/DIFF.
# usage: offcheck.sh <out.txt>   (case list on fd 3 from find; children read /dev/null)
set -u; OUT=$1; T=/tmp/r11u183_off; mkdir -p $T
one() { d=$1; k=$(echo "$d" | md5sum | cut -c1-12)
  ( cd "$d" && /tmp/r11u183_bin/slang-uhdm dut.sv --single-unit --nobuiltin -o $T/$k.p.uhdm >/dev/null 2>&1 </dev/null )
  ( cd "$d" && R11U183_OFF=1 ${LAWBIN:-/tmp/r11u183_bin/slang-uhdm.lawJ} dut.sv --single-unit --nobuiltin -o $T/$k.l.uhdm >/dev/null 2>&1 </dev/null )
  if [ ! -e $T/$k.p.uhdm ] && [ ! -e $T/$k.l.uhdm ]; then echo "SAME-NOOUTPUT $d"; elif cmp -s $T/$k.p.uhdm $T/$k.l.uhdm; then echo "SAME $d"; else echo "DIFF $d"; fi; rm -f $T/$k.p.uhdm $T/$k.l.uhdm; }
export -f one; export T LAWBIN
{ find /tmp/wt_r11u183/tests/probe /tmp/wt_r11u183/tools/probe/r11u183dec/cases -name dut.sv -printf '%h\n' | sort; } > $T/list.txt
xargs -P3 -I{} bash -c 'one "$@"' _ {} < $T/list.txt > "$OUT"
echo "LISTED $(wc -l < $T/list.txt) PROCESSED $(wc -l < "$OUT") SAME $(grep -c "^SAME" "$OUT") DIFF $(grep -c '^DIFF' "$OUT")"

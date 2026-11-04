#!/bin/bash
# away.sh <dirlist> <out>: each listed case dir (absolute, fence-filtered before any file was
# opened) through the pristine and the law binary (dut.sv --single-unit --nobuiltin); one line
# per dir: dir rc_pris md5_pris rc_law md5_law.  Outputs under /tmp/v11u476_away/.
P=/tmp/v11u476_bin/slang-uhdm.pris; L=/tmp/v11u476_bin/slang-uhdm.law
[ -x "$P" ] && [ -x "$L" ] || exit 1
O=/tmp/v11u476_away; mkdir -p $O
while read -r d; do
  [ -d "$d" ] || continue
  k=$(echo "$d" | md5sum | cut -c1-12)
  rm -f $O/$k.p.uhdm $O/$k.l.uhdm
  (cd "$d" && timeout 300 $P dut.sv --single-unit --nobuiltin -o $O/$k.p.uhdm >/dev/null 2>&1 </dev/null); rp=$?
  (cd "$d" && timeout 300 $L dut.sv --single-unit --nobuiltin -o $O/$k.l.uhdm >/dev/null 2>&1 </dev/null); rl=$?
  mp=$(md5sum < $O/$k.p.uhdm 2>/dev/null | cut -c1-12); ml=$(md5sum < $O/$k.l.uhdm 2>/dev/null | cut -c1-12)
  [ "$mp" = "$ml" ] && rm -f $O/$k.p.uhdm $O/$k.l.uhdm
  echo "$d $rp $mp $rl $ml"
done < "$1" > "$2"
echo DONE >> "$2"

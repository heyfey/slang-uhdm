#!/bin/bash
# r11u209: wide byte control. Every tools/probe case dir (dut.sv) run with the pristine and the law binary (parse
# form, check_probe's arguments), the two databases compared byte for byte; prints '<rel> MOVED' / '<rel> FAIL <rcs>'.
# Fence: a dir whose path names a fenced test is skipped (FENCED= line of r11u107repro/canaudit.sh; fail closed).
# usage: bytectl.sh <pristine bin> <law bin> <outdir>
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
PB=$1; LB=$2; O=$3; mkdir -p $O/db
one() { c=$1; k=$(echo $c | sed 's#/#__#g')
  (cd $REPO/$c && timeout 120 $PB dut.sv --single-unit --nobuiltin -o $O/db/$k.p > /dev/null 2>&1); rp=$?
  (cd $REPO/$c && timeout 120 $LB dut.sv --single-unit --nobuiltin -o $O/db/$k.l > /dev/null 2>&1); rl=$?
  if [ -s $O/db/$k.p ] || [ -s $O/db/$k.l ]; then cmp -s $O/db/$k.p $O/db/$k.l && echo "$c SAME $rp $rl" || echo "$c MOVED $rp $rl"; else echo "$c NODB $rp $rl"; fi
  rm -f $O/db/$k.p $O/db/$k.l; }
export -f one; export PB LB O REPO
cd $REPO && find tools/probe -name dut.sv -printf '%h\n' | sort -u | grep -Pvw "$FENCE_RE" | xargs -P3 -I{} bash -c 'one {}' > $O/bytectl.txt
awk '{print $2}' $O/bytectl.txt | sort | uniq -c

#!/bin/bash
# bnd1 <case dir>: pristine vs fix4 bytes, default view. Fence-refusing.
source $(dirname "${BASH_SOURCE[0]}")/env.sh || exit 9
c=$1; rel=$(echo $c | sed -e 's#.*/tools/probe/##')
if echo "$c" | grep -qP "$FENCED_RE"; then echo "FENCED $rel"; exit 0; fi
T=/tmp/v11u192_bnd/w$$; mkdir -p $T; rm -f $T/p.uhdm $T/f.uhdm
(cd $c && timeout 120 ${PRISBIN:?} dut.sv --single-unit --nobuiltin -o $T/p.uhdm > /dev/null 2>&1 </dev/null); rp=$?
(cd $c && timeout 120 ${LAWBIN:?} dut.sv --single-unit --nobuiltin -o $T/f.uhdm > /dev/null 2>&1 </dev/null); rf=$?
if [ ! -s $T/p.uhdm ] && [ ! -s $T/f.uhdm ]; then echo "BOTHFAIL $rel rc=$rp/$rf"
elif cmp -s $T/p.uhdm $T/f.uhdm; then echo "SAME $rel"
else echo "MOVED $rel rc=$rp/$rf"; fi
rm -rf $T

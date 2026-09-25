#!/bin/bash
# coin.sh <dbA> <dbB>: the path-normalised uhdm-dump diff of two databases of the same row, in order and
# order-blind (the UVM UINT/vpiDecompile coin reads 4 order-blind lines, the svunit list-order coin 0).
# Fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "coin.sh: source drivers/env.sh" >&2; exit 2; }
for n in $FENCED; do echo "$1 $2" | grep -qw "$n" && { echo "coin.sh: fenced path refused" >&2; exit 2; }; done
t=${TMPDIR:-/tmp/r11u170_tmp}/coin.$$; mkdir -p $t
norm(){ $UHDM_DUMP $1 2>/dev/null | sed -E 's#/tmp/[^ ,]*/(slang|golden)\.uhdm##g; s#/tmp/r11u170_sw[A-Z0-9]*##g'; }
norm $1 > $t/a; norm $2 > $t/b
echo "ordered=$(diff $t/a $t/b | grep -c '^[<>]') orderblind=$(diff <(sort $t/a) <(sort $t/b) | grep -c '^[<>]')"
rm -rf $t

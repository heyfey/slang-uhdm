#!/bin/bash
# r11u186: the whole-pass switch byte check: every case dir given, the law binary with R11U186_OFF=1 R11U183_OFF=1
# against the pristine binary (bytes of the written database). usage: offcheck.sh <law bin name> <case dir>...
. /tmp/wt_r11u186/tools/probe/r11u186repro/drivers/env.sh || exit 3
L=$1; shift; T=/tmp/r11u186_off; mkdir -p $T
for d in "$@"; do find $(cd $d && pwd) -name dut.sv -printf '%h\n'; done | sort -u > $T/list
same=0; diff=0; nodb=0
while read -r c <&3; do
  for f in $FENCED; do grep -qw "$f" <<< "$c" && continue 2; done
  k=$(echo $c | md5sum | cut -c1-10)
  rm -f $T/$k.p $T/$k.l
  ( cd $c && /tmp/r11u186_bin/pris.bin dut.sv --single-unit --nobuiltin -o $T/$k.p >/dev/null 2>&1 </dev/null )
  ( cd $c && R11U186_OFF=1 R11U183_OFF=1 /tmp/r11u186_bin/$L dut.sv --single-unit --nobuiltin -o $T/$k.l >/dev/null 2>&1 </dev/null )
  if [ ! -e $T/$k.p ] && [ ! -e $T/$k.l ]; then nodb=$((nodb+1)); echo "NODB $c"
  elif cmp -s $T/$k.p $T/$k.l; then same=$((same+1)); else diff=$((diff+1)); echo "DIFF $c"; fi
done 3< $T/list
echo "offcheck $L: listed=$(wc -l < $T/list) same=$same diff=$diff nodb(no database from either binary)=$nodb"

#!/bin/bash
# bytes.sh <dir>... : pristine vs law database bytes on every dut.sv case under each directory (fd-3 list, children </dev/null)
P=${PRIS:-/tmp/r11u145_bin/pristine}; L=${LAW:-/tmp/r11u145_bin/law}; T=$(mktemp -d /tmp/r11u145_by.XXXX)
for d in "$@"; do n=0; m=0; mv=""
  while read -u 3 f; do c=$(dirname $f); n=$((n+1)); k=$(echo $c | md5sum | cut -c1-10)
    (cd $c && $P dut.sv --single-unit --nobuiltin -o $T/$k.p </dev/null >/dev/null 2>&1); (cd $c && $L dut.sv --single-unit --nobuiltin -o $T/$k.l </dev/null >/dev/null 2>&1)
    cmp -s $T/$k.p $T/$k.l || { m=$((m+1)); mv="$mv ${c#$d/}"; }
    rm -f $T/$k.p $T/$k.l
  done 3< <(find $d -name dut.sv | sort)
  echo "$(basename $d) movers $m / $n${mv:+ :$mv}"
done; rm -rf $T

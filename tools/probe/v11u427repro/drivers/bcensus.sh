#!/bin/bash
# v11u427 byte census: pristine, law and verified on every fence-filtered earlier case dir; one line per dir: path rcP md5P rcL md5L rcV md5V
export P=/tmp/v11u427_bin/pristine L=/tmp/v11u427_bin/law V=/tmp/v11u427_bin/verified
for b in "$P" "$L" "$V"; do [ -x "$b" ] || exit 2; done
one() { d=$(dirname /tmp/wt_v11u427/tools/probe/$1); k=$(echo $1 | md5sum | cut -c1-10); TL=""; [ -f $d/TOP ] && TL="--top $(cat $d/TOP)"; out="$1"
 for b in "$P" "$L" "$V"; do o=/tmp/v11u427_bc/$k.$(basename $b).uhdm; rm -f $o; (cd $d && timeout 120 "$b" dut.sv $TL --single-unit --nobuiltin -o $o >/dev/null 2>&1); r=$?; m=$( [ -f $o ] && md5sum < $o | cut -c1-12 || echo none); out="$out $r $m"; rm -f $o; done
 echo "$out"; }
export -f one; mkdir -p /tmp/v11u427_bc
xargs -a /tmp/v11u427_scr/census_list.txt -P 2 -I{} bash -c 'one {}' > /tmp/v11u427_scr/bcensus.txt
echo BCENSUSDONE

#!/bin/bash
# v11u427 census: run the verified binary with the trace on every fence-filtered earlier case dir; log the dirs where a 427v refinement fires
export V=/tmp/v11u427_bin/verified; [ -x "$V" ] || exit 2
T=/tmp/v11u427_ctr; rm -rf $T; mkdir -p $T
one() { d=$(dirname /tmp/wt_v11u427/tools/probe/$1); k=$(echo $1 | md5sum | cut -c1-10); mkdir -p /tmp/v11u427_ctr/$k; TL=""; [ -f $d/TOP ] && TL="--top $(cat $d/TOP)"; (cd $d && R11U427_TRACE=/tmp/v11u427_ctr/$k timeout 120 "$V" dut.sv $TL --single-unit --nobuiltin -o /tmp/v11u427_ctr/$k/o.uhdm >/dev/null 2>&1); echo "$1 rc=$?" >> /tmp/v11u427_ctr/$k/rc; rm -f /tmp/v11u427_ctr/$k/o.uhdm; }
export -f one
xargs -a /tmp/v11u427_scr/census_list.txt -P 2 -I{} bash -c 'one {}'
echo CENSUSDONE

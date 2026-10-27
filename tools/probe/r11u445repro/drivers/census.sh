#!/bin/bash
# usage: census.sh <list of .sv paths relative to the worktree> <out.tsv> [jobs]
# runs PRIS and LAW (env, default the frozen r11u445 binaries) on each file in a copy of its
# directory, LAW with R11U445_TRACE; records path, rc pristine, rc law, md5 pristine, md5 law, firings
WT=${WT:-/tmp/wt_r11u445}; P=${PRIS:-/tmp/r11u445_bin/pristine}; L=${LAW:-/tmp/r11u445_bin/law5}; W=${CW:-/tmp/r11u445_cen}
[ -x "$P" ] && [ -x "$L" ] || { echo "missing binary"; exit 2; }
one() {
  f=$1; d=$W/$(echo $f | tr / _); rm -rf $d; mkdir -p $d/tr; cp $WT/$(dirname $f)/* $d/ 2>/dev/null
  b=$(basename $f)
  (cd $d && timeout 120 $P $b --single-unit --nobuiltin -o p.uhdm >/dev/null 2>&1 </dev/null); rp=$?
  (cd $d && R11U445_TRACE=$d/tr timeout 120 $L $b --single-unit --nobuiltin -o l.uhdm >/dev/null 2>&1 </dev/null); rl=$?
  mp=$(md5sum < $d/p.uhdm 2>/dev/null | cut -c1-8); ml=$(md5sum < $d/l.uhdm 2>/dev/null | cut -c1-8)
  fi=$(cat $d/tr/* 2>/dev/null | grep -vc '^OUT')
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$f" "$rp" "$rl" "$mp" "$ml" "$fi"
}
export -f one; export WT P L W
: > $2
xargs -a $1 -d '\n' -P ${3:-3} -I{} bash -c 'one "$@"' _ {} >> $2

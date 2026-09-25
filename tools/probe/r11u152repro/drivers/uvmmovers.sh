#!/bin/bash
# uvmmovers.sh <outdir>: attribute the surelog byte-only movers (BuildUVMPkg and the UVM coin family
# MiniAmiq / SeqDriver / SimpleUVM / Scoreboard).  Each row is re-run with the law binary and ONE
# switch; the order-blind, path-normalised uhdm-dump diff against the pristine sweep's database says
# which switch removes the movement.  Fail-closed on $FENCED.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "export FENCED" >&2; exit 1; }
O=$1; mkdir -p $O; cd $(dirname $0)/../../../..
F='^(BuildUVMPkg|MiniAmiq|SeqDriver|SimpleUVM|Scoreboard)$'
export SLANG_UHDM=${LAW:-/tmp/r11u152_bin/law2.bin}
for sw in NONE R11U152_CLSVARINIT_OFF R11U152_CLSPANOFILE_OFF R11U152_CLSNESTNAME_OFF R11U152_CGINITEND_OFF R11U152_OFF; do
  ( [ $sw = NONE ] || export $sw=1
    python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$F" \
       --out $O/$sw.csv --workdir $O/wd_$sw > $O/$sw.log 2>&1 )
done

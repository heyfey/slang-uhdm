#!/bin/bash
# switchoff.sh <sweep workdir> <law binary> <out dir> [row] [mode]: per law switch (and R11U234_OFF), the row-mode
# (default BuildUVMPkg default) rewritten with the sweep's own command line under that one switch, then map 15's
# analyzer (drivers/rowclusters.py) against the row's golden: which clusters each law alone clears.
# Fail-closed on $FENCED (source drivers/env.sh); the row name is checked before it is opened.
source "$(dirname "$0")/env.sh" || exit 2
H=$1; BIN=$2; O=$3; t=${4:-BuildUVMPkg}; m=${5:-default}
[ -x "$BIN" ] || { echo "switchoff.sh: $BIN not executable" >&2; exit 2; }
for f in $FENCED; do [ "$f" = "$t" ] && { echo "FENCED refused" >&2; exit 2; }; done
mkdir -p "$O"
d=$(ls -d $H/surelog/$m/$t-* | head -1)
args=$(grep '^slang:' $d/cmds.txt | sed 's/^slang:\s*//; s#^\S* ##; s# -o \S*$##')
gc=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}'); g=$(find $gc -name '*.uhdm' | head -1)
cwd=$(cd $REPO && python3 -c "import sys; sys.path.insert(0,'scripts'); import verify_golden as vg; print(vg.discover_surelog(None)['$t'][0])")
for sw in ${SWITCHES:-R11U234_OFF R11U234_TPTDUSE_OFF R11U234_TPTDFORMAL_OFF R11U234_TPGROUP_OFF R11U234_RETLOCALTS_OFF R11U234_CLSTDRET_OFF R11U234_CLSQUALSPAN_OFF R11U234_PUREVIRTSPAN_OFF}; do
  o=$O/${t}_${m}_$sw.uhdm; rm -f $o
  (cd $cwd && eval "env $sw=1 \"$BIN\" $args -o $o" > $O/${t}_${m}_$sw.log 2>&1); rc=$?
  echo "== $sw rc=$rc md5=$(md5sum < $o | cut -c1-12)"
  python3 $DR/rowclusters.py $g $o $O/${t}_${m}_$sw "$t/$m/$sw" | head -n 1
  cut -f1,2 $O/${t}_${m}_$sw.jsonl >/dev/null 2>&1
  rm -f $o $O/${t}_${m}_$sw.a $O/${t}_${m}_$sw.b $O/${t}_${m}_$sw.tmp
done

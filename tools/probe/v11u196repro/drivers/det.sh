#!/bin/bash
# r11u196: determinism.  Each binary (names in $R196_BIN) runs three times CONCURRENTLY per row-mode (the pristine
# sweep's command line and cwd, output to scratch); prints the distinct md5s per binary and row-mode, and for the UVM
# rows the `types_t` return-twin right-bound values (the r11u191 value coin, uhdm-dump of the weakly referenced tail).
# usage: det.sh <pristine sweep workdir> <bin>... ; env ROWS (default: MiniAmiq SeqDriver SimpleUVM Earlgrey_0_1)
# (fence: refuses fenced rows, fail closed)
. "$(dirname "$0")/env.sh"; R196_BIN=$V196_BIN; R196_REPO=$V196_REPO; r196_fenced() { local f; for f in $FENCED; do grep -qw -- "$f" <<< "$1" && return 0; done; return 1; }
W=$1; shift; O=/tmp/v11u196_det; mkdir -p $O
for t in ${ROWS:-MiniAmiq SeqDriver SimpleUVM Earlgrey_0_1}; do
 r196_fenced "$t" && { echo "det.sh: fenced row refused"; exit 3; }
 for m in default testflags; do
  d=$(ls -d $W/surelog/$m/$t-* 2>/dev/null | head -1); [ -f "$d/cmds.txt" ] || continue
  args=$(grep '^slang:' $d/cmds.txt | sed 's/^slang:\s*//; s#^\S* ##; s# -o \S*$##')
  cwd=$(cd $R196_REPO && python3 -c "import sys; sys.path.insert(0,'scripts'); import verify_golden as vg; print(vg.discover_surelog(None)['$t'][0])")
  for b in "$@"; do
   for i in 1 2 3; do rm -f $O/${t}_${m}_${b}_$i.uhdm; (cd $cwd && eval "$R196_BIN/$b $args -o $O/${t}_${m}_${b}_$i.uhdm" > $O/${t}_${m}_${b}_$i.log 2>&1; echo "rc=$?" >> $O/${t}_${m}_${b}_$i.log) & done; wait
   hs=""; vals=""; for i in 1 2 3; do hs="$hs $(md5sum < $O/${t}_${m}_${b}_$i.uhdm | cut -c1-12)"
     v=$($UHDM_DUMP $O/${t}_${m}_${b}_$i.uhdm 2>/dev/null | awk '/^\\_weaklyReferenced/{w=1} w && /array_typespec: \(types_t\)/{f=1} f && /vpiRightRange/{r=1} r && /(UINT|STRING|INT):/{print $0; f=0; r=0}' | tr -d ' |' | sort | uniq -c | tr -s ' ' | paste -sd',')
     [ -n "$v" ] && vals="$vals [$i:$v]"; done
   echo "$t $m $b distinct=$(echo $hs | tr ' ' '\n' | sort -u | wc -l) hashes:$hs$vals"
  done
 done
done

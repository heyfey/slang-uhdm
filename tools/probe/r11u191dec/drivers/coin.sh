#!/bin/bash
# r11u191 law queueRetTwinDynShape191: the UVM value coin.  Each binary of $COINBINS runs three times CONCURRENTLY per
# row-mode (MiniAmiq, SeqDriver; both modes; the pristine sweep's command line and cwd, output to scratch); prints the
# distinct md5s and the `types_t` return-twin right-bound values (uhdm-dump of the weakly referenced tail).
# usage: coin.sh <pristine sweep workdir>      (the two rows are not fenced; the fence is checked, fail closed)
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3; REPO=$(cd "$HERE/../../../.." && pwd)
W=$1; O=/tmp/r11u191_coin; mkdir -p $O
for t in MiniAmiq SeqDriver; do
 for f in $FENCED; do [ "$f" = "$t" ] && { echo "fenced"; exit 3; }; done
 for m in default testflags; do
  d=$(ls -d $W/surelog/$m/$t-* | head -1)
  args=$(grep '^slang:' $d/cmds.txt | sed 's/^slang:\s*//; s#^\S*slang-uhdm ##; s# -o \S*$##')
  cwd=$(cd $REPO && python3 -c "import sys; sys.path.insert(0,'scripts'); import verify_golden as vg; print(vg.discover_surelog(None)['$t'][0])")
  for b in ${COINBINS:-slang-uhdm slang-uhdm.law}; do
   for i in 1 2 3; do rm -f $O/${t}_${m}_${b}_$i.uhdm; (cd $cwd && eval "$B/$b $args -o $O/${t}_${m}_${b}_$i.uhdm" > $O/${t}_${m}_${b}_$i.log 2>&1; echo "rc=$?" >> $O/${t}_${m}_${b}_$i.log) & done; wait
   vals=""; for i in 1 2 3; do
     v=$($UHDM_DUMP $O/${t}_${m}_${b}_$i.uhdm 2>/dev/null | awk '/^\\_weaklyReferenced/{w=1} w && /array_typespec: \(types_t\)/{f=1} f && /vpiRightRange/{r=1} r && /(UINT|STRING|INT):/{print $0; f=0; r=0}' | tr -d ' |' | sort | uniq -c | tr -s ' ' | paste -sd',')
     vals="$vals [$i: $(md5sum < $O/${t}_${m}_${b}_$i.uhdm | cut -c1-12) $(tail -1 $O/${t}_${m}_${b}_$i.log) $v]"; done
   echo "$t $m $b$vals"
  done
 done
done

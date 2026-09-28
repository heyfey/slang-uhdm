#!/bin/bash
# (r11u208: copied from r11u204verify/drivers, paths renamed; the landings under test are passes 202 and 201.)
# (r11u204: copied from r11u199verify/drivers, paths renamed; the landings under test are passes 196 and 198.)
# (r11u199: copied from r11u194verify/drivers, paths renamed; the landings under test are passes 192 and 193.)
# (r11u194: copied from r11u190verify/drivers, paths renamed; the landings under test are passes 184 and 186.)
# (r11u190: adapted from r11u189map/drivers/det.sh) det.sh <tag> <binary or state wrapper> <reference sweep>: the
# determinism control: the binary three times CONCURRENTLY per row-mode (Earlgrey_0_1 + the five UVM rows), each with
# the reference sweep's recorded command line and the harness's cwd, output to /tmp/r11u208_det/<tag>/.  Prints the
# md5 of each run and of the reference sweep's database.  These six rows are not fenced; fail-closed on $FENCED anyway.
source "$(dirname "$0")/env.sh" || exit 2
N=${DETN:-3}
T=$1; B=$2; R=$3; O=/tmp/r11u208_det/$T; mkdir -p $O
for t in ${DETROWS:-Earlgrey_0_1 MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg}; do
 echo "$t" | grep -Eqw "$(echo $FENCED | tr ' ' '|')" && { echo "$t fenced refused"; continue; }
 for m in default testflags; do
  d=$(ls -d $R/surelog/$m/$t-* 2>/dev/null | head -1); [ -n "$d" ] || continue
  st=$(grep "^$t,$m," $R/surelog.csv | cut -d, -f3); [ "$st" = SLANG_REJECT ] && { echo "$t $m skip $st"; continue; }
  args=$(grep '^slang:' $d/cmds.txt | sed 's/^slang:\s*//; s#^\S* ##; s# -o \S*$##')
  cwd=$(cd $R208_ROOT && python3 -c "import sys; sys.path.insert(0,'scripts'); import verify_golden as vg; print(vg.discover_surelog(None)['$t'][0])")
  for i in $(seq 1 $N); do rm -f $O/${t}_${m}_$i.uhdm; (cd $cwd && eval "$B $args -o $O/${t}_${m}_$i.uhdm" > $O/${t}_${m}_$i.log 2>&1; echo "rc=$?" >> $O/${t}_${m}_$i.log) & done; wait
  echo "$T $t $m $(for i in $(seq 1 $N); do echo -n "$(md5sum < $O/${t}_${m}_$i.uhdm | cut -c1-12)/$(tail -1 $O/${t}_${m}_$i.log) "; done) ref=$(md5sum < $d/slang.uhdm | cut -c1-12)"
 done
done

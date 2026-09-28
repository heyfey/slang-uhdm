#!/bin/bash
# (r11u213: copied from r11u208verify/drivers, paths renamed; the landings under test are passes 206 and 207.)
# (r11u208: copied from r11u204verify/drivers, paths renamed; the landings under test are passes 202 and 201.)
# (r11u204: copied from r11u199verify/drivers, paths renamed; the landings under test are passes 196 and 198.)
# (r11u199: copied from r11u194verify/drivers, paths renamed; the landings under test are passes 192 and 193.)
# (r11u194: copied from r11u190verify/drivers, paths renamed; the landings under test are passes 184 and 186.)
# (r11u190: adapted from r11u189map/drivers/ob.sh) ob.sh <reference sweep> <tag>...: per row-mode, the distinct
# databases among the det.sh runs of the given tags and the reference sweep's; per distinct database the strict verdict
# (uhdm-strictcmp --max 0), the uhdm-cmp line count and the object count; per pair the ORDER-BLIND uhdm-dump difference
# (the database path normalised, sorted, comm -3 line count).  Fail-closed on $FENCED.
source "$(dirname "$0")/env.sh" || exit 2
R=$1; shift; S=/tmp/r11u217_det/sorted; mkdir -p $S
for t in ${DETROWS:-Earlgrey_0_1 MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg}; do
 echo "$t" | grep -Eqw "$(echo $FENCED | tr ' ' '|')" && continue
 for m in default testflags; do
  d=$(ls -d $R/surelog/$m/$t-* 2>/dev/null | head -1); [ -s "$d/slang.uhdm" ] || continue
  declare -A H=(); declare -A W=(); files=()
  for f in $(for tg in "$@"; do ls /tmp/r11u217_det/$tg/${t}_${m}_[0-9]*.uhdm 2>/dev/null; done) $d/slang.uhdm; do
    h=$(md5sum < $f | cut -c1-12); W[$h]="${W[$h]} $(echo $f | sed 's#/tmp/r11u217_det/##; s#/tmp/r11u217_##; s#/surelog/.*#:sweep#; s#\.uhdm##')"
    [ -n "${H[$h]}" ] && continue; H[$h]=$f; files+=($h); done
  g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
  echo "$t $m hashes=${#files[@]}"
  for h in "${files[@]}"; do
    [ -s $S/$h.sorted ] || $UHDM_DUMP ${H[$h]} 2>/dev/null | sed "s#${H[$h]}#DB#g" | LC_ALL=C sort > $S/$h.sorted
    v=$($STRICT_CMP --max 0 $g ${H[$h]} 2>&1 | grep -E '^(STRICT_|NOT_EQUAL|objects)' | tr '\n' ' ')
    cm=$($UHDM_CMP $g ${H[$h]} 2>&1 | wc -l)
    echo "   $h [${W[$h]# }] strict=[$v] cmp_lines=$cm"
  done
  for ((i=0;i<${#files[@]};i++)); do for ((j=i+1;j<${#files[@]};j++)); do
    echo "   ${files[$i]} vs ${files[$j]}: order-blind lines $(LC_ALL=C comm -3 $S/${files[$i]}.sorted $S/${files[$j]}.sorted | wc -l)"; done; done
  unset H W
 done
done

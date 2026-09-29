#!/bin/bash
# r11u222map (map 13's ob.sh, paths from env.sh): order-blind distance between the distinct databases of each row-mode
# (the DETN concurrent runs in $DETOUT + the HEAD sweep's database when DETHEAD=1, + any sweep dirs in $DETEXTRA), with
# the strict verdict and the uhdm-cmp line count of each variant.
. "$(dirname "$0")/env.sh"
O=${DETOUT:?}; S=${DETSORT:-$W/det_sorted}; N=${DETN:-3}; mkdir -p $S
for v in UHDM_DUMP UHDM_CMP STRICT_CMP; do [ -x "${!v}" ] || { echo "ob.sh: $v not executable" >&2; exit 2; }; done
for t in ${DETTESTS:-Earlgrey_0_1 MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg}; do
 echo "$t" | grep -Pq "$FENCERE" && { echo "FENCED refused"; continue; }
 for m in default testflags; do
  [ -s $O/${t}_${m}_1.uhdm ] || continue
  d=$(ls -d $H/surelog/$m/$t-* | head -1)
  declare -A HH=(); files=()
  fl="$(for i in $(seq 1 $N); do echo $O/${t}_${m}_$i.uhdm; done)"; [ "${DETHEAD:-1}" = 1 ] && fl="$fl $d/slang.uhdm"
  for x in ${DETEXTRA:-}; do e=$(ls -d $x/surelog/$m/$t-* 2>/dev/null | head -1); [ -s "$e/slang.uhdm" ] && fl="$fl $e/slang.uhdm"; done
  for f in $fl; do h=$(md5sum < $f | cut -c1-12); [ -n "${HH[$h]}" ] && continue; HH[$h]=$f; files+=($h); done
  g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
  line="$t $m hashes=${#files[@]}"
  for h in "${files[@]}"; do
    [ -s $S/$h.sorted ] || { $UHDM_DUMP ${HH[$h]} 2>/dev/null | sed "s#${HH[$h]}#DB#g" > $S/$h.raw; LC_ALL=C sort $S/$h.raw > $S/$h.sorted; }
    v=$($STRICT_CMP --max 0 $g ${HH[$h]} 2>&1 | grep -o '^STRICT_[A-Z]*.*' | head -1)
    cm=$($UHDM_CMP $g ${HH[$h]} 2>&1 | wc -l)
    line="$line | $h strict=[$v] cmp_lines=$cm"
  done
  echo "$line"
  for ((i=0;i<${#files[@]};i++)); do for ((j=i+1;j<${#files[@]};j++)); do
    echo "   ${files[$i]} vs ${files[$j]}: order-blind lines $(LC_ALL=C comm -3 $S/${files[$i]}.sorted $S/${files[$j]}.sorted | wc -l), raw dump lines $(diff $S/${files[$i]}.raw $S/${files[$j]}.raw | grep -c '^[<>]')"; done; done
  unset HH
 done
done

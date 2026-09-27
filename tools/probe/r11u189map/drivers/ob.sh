#!/bin/bash
# order-blind distance between the distinct databases of each row-mode (3 concurrent runs + the HEAD sweep's)
O=/tmp/r11u189_det/out; S=/tmp/r11u189_det/sorted; mkdir -p $S
DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
for t in Earlgrey_0_1 MiniAmiq SeqDriver SimpleUVM Scoreboard BuildUVMPkg; do
 for m in default testflags; do
  [ -s $O/${t}_${m}_1.uhdm ] || continue
  d=$(ls -d /tmp/intr11u185/surelog/$m/$t-* | head -1)
  declare -A H=(); files=()
  for f in $O/${t}_${m}_1.uhdm $O/${t}_${m}_2.uhdm $O/${t}_${m}_3.uhdm $d/slang.uhdm; do h=$(md5sum < $f | cut -c1-12); [ -n "${H[$h]}" ] && continue; H[$h]=$f; files+=($h); done
  g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
  line="$t $m hashes=${#files[@]}"
  for h in "${files[@]}"; do
    [ -s $S/$h.sorted ] || $DUMP ${H[$h]} 2>/dev/null | sed "s#${H[$h]}#DB#g" | LC_ALL=C sort > $S/$h.sorted
    v=$(/tmp/r11u189_bin/uhdm-strictcmp --max 0 $g ${H[$h]} 2>&1 | grep -o '^STRICT_[A-Z]*.*' | head -1)
    cm=$(/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp $g ${H[$h]} 2>&1 | wc -l)
    line="$line | $h strict=[$v] cmp_lines=$cm"
  done
  echo "$line"
  for ((i=0;i<${#files[@]};i++)); do for ((j=i+1;j<${#files[@]};j++)); do
    echo "   ${files[$i]} vs ${files[$j]}: order-blind lines $(LC_ALL=C comm -3 $S/${files[$i]}.sorted $S/${files[$j]}.sorted | wc -l)"; done; done
  unset H
 done
done

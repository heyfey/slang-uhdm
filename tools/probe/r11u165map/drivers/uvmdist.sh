#!/bin/bash
# r11u165: the order-blind uhdm-dump distance to golden of the UVM rows, per binary. For each row-mode and each
# sweep workdir given: uhdm-dump golden and ours, normalise the workdir paths, sort (LC_ALL=C), and count the lines
# only in golden (G-only), only in ours (O-only) and their sum. A UVM row is none of the slang-fenced tests; the
# fence is still checked (fail closed): FENCED must hold four names and no row below may match one.
# usage: uvmdist.sh <tag=workdir> ...   (workdir holds <mode>/<test>-<hash>/{slang.uhdm,cmds.txt})
set -u
[ "$(echo ${FENCED:-} | wc -w)" = 4 ] || { echo "uvmdist.sh: export FENCED" >&2; exit 2; }
: "${UHDM_DUMP:?}"
ROWS="MiniAmiq/default MiniAmiq/testflags SeqDriver/default SeqDriver/testflags SimpleUVM/default SimpleUVM/testflags Scoreboard/default BuildUVMPkg/default BuildUVMPkg/testflags"
T=${TMPD:-/tmp/r11u165_uvmdist}; mkdir -p $T
printf 'row'; for a in "$@"; do printf '\t%s(G-only+O-only=sum)' "${a%%=*}"; done; echo
for rm in $ROWS; do
  t=${rm%/*}; m=${rm#*/}
  for f in $FENCED; do [ "$t" = "$f" ] && { echo "fenced row refused" >&2; exit 3; }; done
  printf '%s' "$rm"
  for a in "$@"; do
    tag=${a%%=*}; wd=${a#*=}
    d=$(ls -d $wd/$m/$t-* 2>/dev/null | head -1)
    if [ -z "$d" ] || [ ! -s "$d/slang.uhdm" ]; then printf '\t-'; continue; fi
    g=$(grep -o 'golden cache [a-z]* [^)]*' $d/cmds.txt | awk '{print $4}')/golden.uhdm
    gk=$T/g_${t}_$m.txt
    [ -s $gk ] || $UHDM_DUMP $g 2>/dev/null | sed -E 's#/home/heyfey/[^ ]*/(third_party|tests)/#ROOT/\1/#g' | LC_ALL=C sort > $gk
    $UHDM_DUMP $d/slang.uhdm 2>/dev/null | sed -E "s#$wd#WD#g; s#/home/heyfey/[^ ]*/(third_party|tests)/#ROOT/\1/#g; s#/tmp/[^ ]*/(third_party|tests)/#ROOT/\1/#g" | LC_ALL=C sort > $T/o.txt
    go=$(LC_ALL=C comm -23 $gk $T/o.txt | wc -l); oo=$(LC_ALL=C comm -13 $gk $T/o.txt | wc -l)
    printf '\t%s+%s=%s' $go $oo $((go + oo))
  done
  echo
done

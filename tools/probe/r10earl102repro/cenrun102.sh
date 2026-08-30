#!/usr/bin/env bash
# r10earl102 CORPUS CENSUS DRIVER -- MEASUREMENT ONLY.
#   cenrun102.sh <verify_golden-workdir> <outdir>
# For every <mode>/<test>-<hash>/ directory that holds a slang.uhdm AND names a
# golden cache entry in its own cmds.txt, run ct102cen on BOTH sides and write
#   <outdir>/<mode>__<test>.gold.txt / .ours.txt
# The golden path is read out of the workdir's OWN cmds.txt (never guessed), a
# missing side is printed as SKIP and COUNTED, and every ct102cen rc is logged.
set -u
WD=${1:?workdir}; OUT=${2:?outdir}
HERE=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$OUT"
n=0; skip=0; bad=0
: > "$OUT/RUN.log"
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    O="$d/slang.uhdm"; C="$d/cmds.txt"
    t=$(basename "$d"); t=${t%-*}
    G=""
    [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G="$G/golden.uhdm"
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      echo "SKIP $mode $t" >> "$OUT/RUN.log"; skip=$((skip+1)); continue
    fi
    "$HERE/ct102cen" "$G" > "$OUT/${mode}__${t}.gold.txt" 2>>"$OUT/RUN.log"; g=$?
    "$HERE/ct102cen" "$O" > "$OUT/${mode}__${t}.ours.txt" 2>>"$OUT/RUN.log"; o=$?
    echo "RC $mode $t gold=$g ours=$o" >> "$OUT/RUN.log"
    [ "$g" != 0 ] || [ "$o" != 0 ] && bad=$((bad+1))
    n=$((n+1))
  done
done
echo "CENSUSED=$n SKIP=$skip BADRC=$bad" | tee -a "$OUT/RUN.log"

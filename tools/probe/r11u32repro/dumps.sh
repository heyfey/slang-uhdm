#!/bin/bash
# r11u32: dump golden + ours for each test of a workdir, normalise the workdir
# path away, and SECTION by |uhdmtopModules: into DEF / ELAB / TAIL.
# usage: dumps.sh <workdir> <mode> <outdir>
set -u
WD=${1:?workdir}; MODE=${2:?mode}; OUT=${3:?outdir}
DUMP=/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump"; exit 3; }
mkdir -p "$OUT"
for d in "$WD/$MODE"/*/; do
  n=$(basename "$d"); n=${n%-*}
  O=$d/slang.uhdm
  C=$d/cmds.txt
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" 2>/dev/null | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
    echo "$n SKIP-NOFILE"; continue
  fi
  for side in g o; do
    [ $side = g ] && SRC=$G || SRC=$O
    # re-read to byte-stable (a partially written dump reads like a result)
    "$DUMP" "$SRC" 2>/dev/null | sed -e "s#$WD##g" -e "s#$G##g" > "$OUT/$n.$MODE.$side.raw"
  done
  echo "$n $(wc -l < "$OUT/$n.$MODE.g.raw") $(wc -l < "$OUT/$n.$MODE.o.raw")"
done

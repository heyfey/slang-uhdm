#!/usr/bin/env bash
# r10earl110 CALIBRATION -- golden vs golden, BEFORE any code is scored.
# Each arm's Surelog golden is built TWICE in two different directories and the
# two censuses are scored against each other; anything but 0 DIFF means the
# instrument, not the emitter, is moving.  (A UHDM database records the source
# file's ABSOLUTE path -- r10buvm8's trap -- so both builds run on the SAME
# source path and differ only in the output directory.)
set -u
SL=$HOME/git-repos/Surelog/build/bin/surelog
HERE=$(cd "$(dirname "$0")" && pwd)
CEN=$HERE/cen110
OUT=${1:?outdir}; mkdir -p "$OUT"
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
bad=0; n=0
for f in "$HERE"/g?_*110.sv; do
  arm=$(basename "$f" .sv)
  t=$(awk -v a="$arm" '$1==a{print $2}' "$HERE/TOPS.txt" | head -1)
  T=""; [ -n "$t" ] && T="-top $t"
  for view in plain elab; do
    case $view in plain) SLF="-parse";; elab) SLF="-parse -elabuhdm";; esac
    for r in r1 r2; do
      d="$OUT/${arm}_${view}_$r"; mkdir -p "$d"; rm -rf "$d/sl"
      ( cd "$d" && $SL $SLF -nobuiltin -nocache -mt 0 -mp 0 -d uhdm -o sl $T "$f" > sl.log 2>&1 </dev/null )
      G=$(find "$d/sl" -name '*.uhdm' 2>/dev/null | head -1)
      if [ -z "${G:-}" ]; then echo "CALIB-REJECT $arm $view $r"; bad=$((bad+1)); continue; fi
      "$CEN" "$G" "${arm}_${view}" > "$d/cen.txt" 2>&1
    done
    A="$OUT/${arm}_${view}_r1/cen.txt"; B="$OUT/${arm}_${view}_r2/cen.txt"
    if [ -f "$A" ] && [ -f "$B" ]; then
      c=$(grep -c '^' "$A"; true)
      if diff -q "$A" "$B" >/dev/null; then
        echo "CALIB OK   $arm $view rows=$c"
      else
        echo "CALIB DIFF $arm $view"; diff "$A" "$B" | head -10; bad=$((bad+1))
      fi
      n=$((n+c-1))
    fi
  done
done
echo "-- CALIB cells=$n BAD=$bad"

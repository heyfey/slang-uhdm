#!/usr/bin/env bash
# r10uvm168repro/cenrun168.sh — run ct168cen over EVERY comparable row of a
# verify_golden workdir.  MEASUREMENT ONLY.
#   cenrun168.sh <workdir> <out.txt> [<name-filter>]
# The golden path comes from each row's OWN cmds.txt (so the census cannot
# silently compare against the wrong golden), BOTH sides are existence-checked,
# and a row whose census tool fails is printed as CENSUS_FAIL and COUNTED — a
# driver that reaches nothing must never read as perfection.
set -u
WD=${1:?workdir}; OUT=${2:?out}; F=${3:-}
CEN=${CT168CEN:-/tmp/r10uvm168_ct168cen}
[ -x "$CEN" ] || { echo "FATAL no ct168cen at $CEN"; exit 3; }
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib:${LD_LIBRARY_PATH:-}
: > "$OUT"
rows=0; skipped=0; failed=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    n=$(basename "$d")
    [ -n "$F" ] && case "$n" in *"$F"*) ;; *) continue;; esac
    O=$d/slang.uhdm
    C=$d/cmds.txt
    G=""
    [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
      skipped=$((skipped+1)); continue
    fi
    if ! "$CEN" "$G" "$O" "$mode/$n" ${CT168_ALL:+all} >> "$OUT" 2>>"$OUT.err"; then
      echo "CENSUS_FAIL $mode/$n" >> "$OUT"; failed=$((failed+1))
    fi
    rows=$((rows+1))
  done
done
echo "CENRUN rows=$rows skipped=$skipped census_fail=$failed" | tee -a "$OUT"

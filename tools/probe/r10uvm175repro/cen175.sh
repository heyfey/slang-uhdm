#!/usr/bin/env bash
# r10uvm175 — THE CORPUS CENSUS.  For every row of a `verify_golden` workdir,
# run `ct175cen` on the GOLDEN database and on OURS and score the hier_path
# element-shape vectors with `score175.py`.  MEASUREMENT ONLY; the official
# uhdm-cmp is the judge.  LHS is ALWAYS golden.
#
#   CEN=<ct175cen> cen175.sh <pristine workdir> [<patched workdir>] [<name-filter>]
#
# Ops traps this driver pays for:
#   * the golden path is read out of the row's OWN cmds.txt (so the census can
#     never silently compare against the wrong golden) and the cache DIRECTORY
#     is turned into `.../golden.uhdm`;
#   * a row whose golden or ours is missing prints SKIP and is COUNTED — a
#     driver that reaches nothing must never read as perfection;
#   * every ct175cen invocation records its own rc.
set -u
WP=${1:?pristine workdir}
WQ=${2:-}
FILT=${3:-}
CEN=${CEN:-/tmp/r10uvm175_bin/ct175cen}
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCR=$HERE/score175.py
TMP=$(mktemp -d /tmp/r10uvm175_cen.XXXXXX) || exit 9
trap 'rm -rf "$TMP"' EXIT
rows=0; skip=0
for d in "$WP"/*/*/; do
  case "$d" in *"$FILT"*) ;; *) continue;; esac
  mode=$(basename "$(dirname "$d")")
  name=$(basename "$d")
  O=$d/slang.uhdm
  C=$d/cmds.txt
  G=""
  [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$O" ]; then
    skip=$((skip+1)); continue
  fi
  rows=$((rows+1))
  "$CEN" "$G" > "$TMP/g.cells" 2>"$TMP/g.err"; rcg=$?
  "$CEN" "$O" > "$TMP/p.cells" 2>"$TMP/p.err"; rcp=$?
  Q=""
  if [ -n "$WQ" ] && [ -f "$WQ/$mode/$name/slang.uhdm" ]; then
    "$CEN" "$WQ/$mode/$name/slang.uhdm" > "$TMP/q.cells" 2>"$TMP/q.err"
    echo "  rc_q=$?" > /dev/null
    Q=$TMP/q.cells
  fi
  python3 "$SCR" "$TMP/g.cells" "$TMP/p.cells" "$Q" \
      "$name/$mode(rcg=$rcg,rcp=$rcp)" > "$TMP/out.txt" 2>&1
  head -1 "$TMP/out.txt"
  if [ -n "${OUTDIR:-}" ]; then
    mkdir -p "$OUTDIR"
    cp "$TMP/out.txt" "$OUTDIR/$name.$mode.score"
    python3 "$SCR" "$TMP/g.cells" "$TMP/p.cells" "$Q" \
        "$name/$mode" --judge > "$OUTDIR/$name.$mode.judge" 2>&1
  fi
done
echo "-- CENSUS rows=$rows SKIP=$skip"

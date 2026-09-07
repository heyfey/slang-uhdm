#!/usr/bin/env bash
# r10earl119 — THE GRID.  Every arm x BOTH VIEWS (default = no flag, elab =
# -elabuhdm/--elabuhdm) x GOLDEN + BOTH BINARIES.  MEASUREMENT ONLY: the
# databases are dumped with uhdm-dump and every cell is read out of the dump by
# the reader `gridread119.py`; every rc is recorded.
#
#   grid119.sh <outdir> <pristine-bin> <patched-bin> <arm.sv> [arm.sv ...]
#
# Nothing here is an acceptance judge.
set -u
OUT=${1:?outdir}; PRIS=${2:?pristine}; PATCHED=${3:?patched}; shift 3
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
mkdir -p "$OUT"
: > "$OUT/rc.txt"
for arm in "$@"; do
  base=$(basename "$arm" .sv)
  d=$(cd "$(dirname "$arm")" && pwd)
  f=$(basename "$arm")
  for view in def elab; do
    slflag=""; suflag=""
    [ "$view" = elab ] && { slflag="-elabuhdm"; suflag="--elabuhdm"; }
    w="$OUT/$base.$view"
    mkdir -p "$w"
    ( cd "$d" && $SURELOG -parse -sv $slflag -mt 0 -mp 0 -o "$w/gold" "$f" ) \
        > "$w/surelog.log" 2>&1
    echo "$base $view surelog rc=$?" >> "$OUT/rc.txt"
    g=$(ls "$w"/gold/slpp_all/*.uhdm 2>/dev/null | head -1)
    [ -n "$g" ] && cp "$g" "$w/golden.uhdm"
    for side in pris patched; do
      bin=$PRIS; [ "$side" = patched ] && bin=$PATCHED
      ( cd "$d" && "$bin" $suflag --single-unit "$f" -o "$w/$side.uhdm" ) \
          > "$w/$side.log" 2>&1
      echo "$base $view $side rc=$?" >> "$OUT/rc.txt"
    done
    for side in golden pris patched; do
      [ -f "$w/$side.uhdm" ] || continue
      "$DUMP" "$w/$side.uhdm" > "$w/$side.dump" 2>"$w/$side.dump.err"
      echo "$base $view $side dump rc=$?" >> "$OUT/rc.txt"
    done
  done
done

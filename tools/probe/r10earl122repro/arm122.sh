#!/usr/bin/env bash
# r10earl122 ARM RUNNER — one .sv arm, both views, golden + one or two of our
# binaries, with the official `uhdm-cmp` count and the cen122 binding census.
#
# MEASUREMENT ONLY.  `uhdm-cmp` is the judge; nothing here decides acceptance.
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# THE TWO-SURELOG TRAP (r10earl120's R4, r10earl121's R4): the golden side is
# built with the surelog `scripts/verify_golden.py` names, SPELLED IN FULL.
# The shell `surelog` alias is a DIFFERENT build.
#
# usage: ARMS="a1_axis122.sv ..." PRIS=<bin> [PAT=<bin>] bash arm122.sh <outdir>
set -u
SURELOG=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/.local/bin/uhdm-cmp
CEN=${CEN122:-/tmp/r10earl122_cen122}
SRCDIR=${SRCDIR:-$(cd "$(dirname "$0")" && pwd)}
OUT=${1:?outdir}; mkdir -p "$OUT"
PRIS=${PRIS:?}; PAT=${PAT:-}
for arm in $ARMS; do
  base=$(basename "$arm" .sv)
  for view in plain elab; do
    case $view in plain) SLF="-parse"; OUF="";; elab) SLF="-parse -elabuhdm"; OUF="--elabuhdm";; esac
    g="$OUT/${base}_${view}_G"; mkdir -p "$g"; cp "$SRCDIR/$arm" "$g/"
    ( cd "$g" && $SURELOG $SLF -nobuiltin -nocache -sv -mt 0 -mp 0 -o . "$arm" > sl.log 2>&1 </dev/null )
    echo "GRC $base $view $?" >> "$OUT/rc.txt"
    gu=$(ls "$g"/slpp_all/*.uhdm "$g"/slpp_unit/*.uhdm 2>/dev/null | head -1)
    for side in P X; do
      case $side in P) BIN=$PRIS;; X) BIN=$PAT;; esac
      [ -n "$BIN" ] || continue
      d="$OUT/${base}_${view}_$side"; mkdir -p "$d"; cp "$SRCDIR/$arm" "$d/"
      ( cd "$d" && "$BIN" $OUF "$arm" -o slang.uhdm > slang.log 2>&1 </dev/null )
      rc=$?
      echo "ORC $base $view $side $rc" >> "$OUT/rc.txt"
      if [ -n "$gu" ] && [ -f "$d/slang.uhdm" ]; then
        n=$($CMP "$gu" "$d/slang.uhdm" 2>&1 | grep -c . ; true)
        echo -e "CMP\t$base\t$view\t$side\t$n" >> "$OUT/grid.txt"
        $CMP "$gu" "$d/slang.uhdm" > "$d/head.cmp" 2>&1
      else
        echo -e "CMP\t$base\t$view\t$side\tNO-DB" >> "$OUT/grid.txt"
      fi
      [ -f "$d/slang.uhdm" ] && "$CEN" "$d/slang.uhdm" 2>/dev/null | grep '^CELL' | sort > "$d/cen.txt"
    done
    [ -n "$gu" ] && "$CEN" "$gu" 2>/dev/null | grep '^CELL' | sort > "$g/cen.txt"
  done
done
sort "$OUT/grid.txt" -o "$OUT/grid.txt"
cat "$OUT/grid.txt"

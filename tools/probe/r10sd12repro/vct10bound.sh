#!/usr/bin/env bash
# r10sd10 — THE BOUNDARY RE-RUN.  Every earlier pass's grid, on BOTH binaries,
# scored on the three measures that can move independently: the uhdm-cmp
# verdict, the head count, and the DUMP CONTENT count.  A cell whose OWN dump is
# byte-identical between the two binaries is reported IDENTICAL; anything else
# is printed in full and never summarised.
#
#   usage: PRIS=<pristine> PATCHED=<patched> ./ct10bound.sh [griddir ...]
#
# GUARD: a grid directory with no cells, or a cell that produces no dump on
# either binary, is a hard error — a boundary check that reaches nothing reads
# exactly like a boundary check that passes.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
PRIS=${PRIS:?set PRIS}
PATCHED=${PATCHED:?set PATCHED}
DIRS=${*:-"qgrid4 grid6 grid7 grid7v grid8 vgrid8 grid9"}
bad=0; ident=0; moved=0; cells=0
for gd in $DIRS; do
  [ -d "$HERE/$gd" ] || { echo "FATAL: no grid dir $gd"; exit 3; }
  n=$(ls "$HERE/$gd"/*.sv 2>/dev/null | wc -l)
  [ "$n" -gt 0 ] || { echo "FATAL: $gd has no cells"; exit 4; }
  echo "======== $gd ($n cells)"
  for c in $(cd "$HERE/$gd" && ls *.sv); do
    b=${c%.sv}
    cells=$((cells + 1))
    for arm in pris patched; do
      if [ "$arm" = pris ]; then BIN=$PRIS; else BIN=$PATCHED; fi
      D=/tmp/vsd11_bnd_${arm}_${gd}_$b
      out=$(SLANG_UHDM="$BIN" "$HERE/ct8arm.sh" "$gd/$c" "$D" 2>&1)
      eval "v_$arm=\$(echo \"\$out\" | grep -E '^(PASS_CMP|CMP_FAIL|SURELOG_FAIL|NO_OUTPUT)')"
      eval "h_$arm=\$(echo \"\$out\" | grep -oE 'heads=[0-9]+')"
      eval "c_$arm=\$(echo \"\$out\" | grep -oE 'content=[0-9]+' || echo content=0)"
    done
    # uhdm-dump EMBEDS THE WORKDIR PATH in every `file:` field, and the two arms
    # run in DIFFERENT directories by construction (Surelog synthesises
    # builtin.sv into the cwd).  Comparing the raw dumps reported all 44 cells
    # as MOVED on the first run of this script — the same trap that caught
    # r10sd9's verifier.  NORMALISE BOTH SIDES FIRST.
    P0=/tmp/vsd11_bnd_pris_${gd}_$b/o.dump
    Q0=/tmp/vsd11_bnd_patched_${gd}_$b/o.dump
    P=$P0.norm; Q=$Q0.norm
    [ -f "$P0" ] && sed 's#/tmp/vsd11_bnd_[a-z]*_[A-Za-z0-9_]*/#WD/#g' "$P0" > "$P"
    [ -f "$Q0" ] && sed 's#/tmp/vsd11_bnd_[a-z]*_[A-Za-z0-9_]*/#WD/#g' "$Q0" > "$Q"
    if [ ! -f "$P" ] || [ ! -f "$Q" ]; then
      echo "  $b  NO_DUMP pris=[$v_pris] patched=[$v_patched]  <- CANNOT SCORE"
      bad=$((bad + 1)); continue
    fi
    if cmp -s "$P" "$Q"; then
      ident=$((ident + 1))
      echo "  $b  IDENTICAL  [$v_pris $h_pris $c_pris]"
    else
      moved=$((moved + 1))
      echo "  $b  MOVED  pris=[$v_pris $h_pris $c_pris] patched=[$v_patched $h_patched $c_patched]"
      diff -u "$P" "$Q" | grep -E '^[-+]' | grep -vE '^(---|\+\+\+) ' | sed 's/^/      /'
    fi
  done
done
echo "[S] cells=$cells IDENTICAL=$ident MOVED=$moved UNSCORABLE=$bad"
[ "$cells" -gt 0 ] || { echo "REFUSING TO REPORT: no cells"; exit 4; }
[ "$bad" -eq 0 ] || exit 5

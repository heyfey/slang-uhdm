#!/bin/bash
# r10uvm212 — THE GOLDEN GRID DRIVER.  MEASUREMENT ONLY.  Runs the canonical
# golden-side Surelog (the one `scripts/verify_golden.py` names) and a NAMED
# slang-uhdm binary over every arm SUBDIRECTORY of `grid/`, then censuses both
# databases with ct212cen.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
#
# GUARDS (each an ops trap this campaign has paid for):
#   * SUBDIRECTORY arms are found with `find`, not a top-level glob — a
#     top-level glob runs nothing and prints green;
#   * the arm list is read on fd 3 and every child gets `</dev/null`, so a child
#     cannot swallow the list;
#   * PROCESSED is asserted equal to LISTED at the end;
#   * scratch is keyed on the arm's RELATIVE PATH (arms may share a basename);
#   * EVERY cell records the process rc — verify_golden.py records rc=139
#     SEGFAULTS as a reject wearing the last stderr warning, so an rc that is
#     not printed is an rc that can hide;
#   * the slang binary is taken from $SLANG_UHDM and PRINTED, because both
#     harness scripts silently default to the main-tree binary.
#
#   usage: SLANG_UHDM=<binary> OUT=<dir> grid212.sh [<arm-name-substring>]
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
UVMSRC=$HOME/git-repos/Surelog/third_party/UVM/uvm-1.2/src
BIN=${SLANG_UHDM:?export SLANG_UHDM to the frozen binary under test}
OUT=${OUT:?set OUT to the scratch directory for this run}
CEN=${CT212CEN:?set CT212CEN to the built ct212cen}
FILT=${1:-}
# CENARG=--full makes ct212cen print EVERY class_typespec, not only the
# registry-typedef family; the small self-contained cells need it because their
# typedef is named `tidb`, not `type_id`.
CENARG=${CENARG:-}
# GRIDDIR lets a FROZEN copy of this script (run from outside the probe dir)
# still find the arms; it defaults to the arms beside the script.
GRIDDIR=${GRIDDIR:-$HERE/grid}
[ -x "$SL" ] || { echo "FATAL: no surelog at $SL"; exit 3; }
[ -x "$BIN" ] || { echo "FATAL: no slang-uhdm at $BIN"; exit 3; }
echo "SURELOG   = $SL"
echo "SLANG     = $BIN  md5=$(md5sum "$BIN" | cut -c1-32)"
echo "OUT       = $OUT"
mkdir -p "$OUT" || exit 1

LIST=$OUT/arms.txt
find "$GRIDDIR" -mindepth 1 -maxdepth 1 -type d | sort > "$LIST"
listed=$(grep -c . "$LIST" || true)
echo "LISTED=$listed"
# A gate that reaches NOTHING must never read as perfection.
[ "$listed" -gt 0 ] || { echo "GATE FAIL: no arms under $GRIDDIR"; exit 4; }
proc=0
while read -r arm <&3; do
  rel=${arm#$GRIDDIR/}
  name=$(basename "$arm")
  case "$name" in *"$FILT"*) ;; *) continue;; esac
  key=$(echo "$rel" | tr '/' '_')          # scratch keyed on the RELATIVE PATH
  W=$OUT/$key
  mkdir -p "$W"
  # The invocation MIRRORS scripts/verify_golden.py's `default` mode EXACTLY
  # (`run_one`, the `if 'default' in modes` arm): cwd = the source directory,
  # `-parse` + `precompiled_guard` (`-noprecompiledcache`, because `uvm_pkg.sv`
  # is a PRECOMPILED LEAF and is emphatically NOT a no-op on the Surelog side)
  # + the location args + `-sv` + the sources, with `-mt 0 -mp 0 -o <workdir>`.
  # Two traps paid for here: the corpus's `-nobuiltin -nocache` belong to the
  # uhdm2rtlil runner and NOT to this one (they made Surelog swallow the
  # `+incdir+` token as a FILENAME and die FTL with an empty database), and the
  # `+incdir+` must be the RELATIVE `.`-first form the `.sl` files carry.
  #
  # An arm that carries a `USE_UVM` marker file is compiled WITH the uvm-1.2
  # sources (minutes per arm); one without it is a self-contained cell (seconds).
  UVMARGS_SL=(); UVMARGS_SU=()
  if [ -f "$arm/USE_UVM" ]; then
    UVMARGS_SL=(-noprecompiledcache "+incdir+.+$UVMSRC/" -sv "$UVMSRC/uvm_pkg.sv")
    UVMARGS_SU=("+incdir+.+$UVMSRC/" "$UVMSRC/uvm_pkg.sv")
  else
    UVMARGS_SL=(-sv)
  fi
  ( cd "$arm" && "$SL" -parse "${UVMARGS_SL[@]}" design.sv \
        -mt 0 -mp 0 -o "$W" > "$W/surelog.log" 2>&1 </dev/null )
  grc=$?
  G=$(ls "$W"/slpp_all/*.uhdm "$W"/slpp_unit/*.uhdm 2>/dev/null | head -1)
  ( cd "$arm" && "$BIN" ${UVMARGS_SU[@]+"${UVMARGS_SU[@]}"} design.sv \
        --single-unit -o "$W/slang.uhdm" > "$W/slang.log" 2>&1 </dev/null )
  orc=$?
  gcells="-"; ocells="-"
  if [ -n "$G" ] && [ -f "$G" ]; then
    "$CEN" "$G" $CENARG > "$W/golden.cen" 2>&1
    gcells=$(grep -c '^x' "$W/golden.cen" || true)
  fi
  if [ -f "$W/slang.uhdm" ]; then
    "$CEN" "$W/slang.uhdm" $CENARG > "$W/ours.cen" 2>&1
    ocells=$(grep -c '^x' "$W/ours.cen" || true)
  fi
  printf "ARM %-22s surelog rc=%-3s db=%-4s rows=%-4s | slang rc=%-3s db=%-3s rows=%-4s\n" \
    "$name" "$grc" "$([ -n "$G" ] && echo yes || echo NO)" "$gcells" \
    "$orc" "$([ -f "$W/slang.uhdm" ] && echo yes || echo NO)" "$ocells"
  proc=$((proc+1))
done 3< "$LIST"
echo "PROCESSED=$proc LISTED=$listed FILTER='${FILT}'"
if [ "$proc" -eq 0 ]; then
  echo "GATE FAIL: PROCESSED=0"; exit 4
fi
if [ -z "$FILT" ] && [ "$proc" != "$listed" ]; then
  echo "GATE FAIL: PROCESSED != LISTED"; exit 4
fi
echo "GRID OK"

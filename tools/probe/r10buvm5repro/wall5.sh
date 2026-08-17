#!/usr/bin/env bash
# r10buvm5 — THE FIVE-ROW WALL CHECK.
#
#   usage: wall5.sh <pristine-workdir-root> <patched-workdir-root> <outdir>
#
# SeqDriver / SimpleUVM / Scoreboard (cmp 1450011 / 1405511 / 1399779 lines) must
# not regress.  Their DATABASES DO move under this pass, so a line COUNT is not
# enough: this runs uhdm-cmp on BOTH sides and requires the cmp OUTPUT to be
# BYTE-IDENTICAL, which is the only reading that distinguishes "same wall" from
# "same size, different wall".
#
# GUARDS:
#   * uhdm-cmp EXITS 0 WHEN AN INPUT IS MISSING, so every input is existence-
#     checked and a missing one is FATAL, never green.
#   * the golden path is read out of each workdir's OWN cmds.txt, so the two
#     sides can never be compared against different goldens.
#   * a row whose database did NOT move is reported as SAME-DB and still cmp'd.
set -u
PRIS=${1:?pristine workdir root}
PATCHED=${2:?patched workdir root}
OUT=${3:?outdir}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
[ -x "$CMP" ] || { echo "FATAL: no uhdm-cmp at $CMP"; exit 3; }
mkdir -p "$OUT" || exit 1
rc=0
for n in SeqDriver SimpleUVM Scoreboard; do
  for mode in default testflags; do
    for d in "$PRIS/$mode/$n"-*/; do
      [ -d "$d" ] || continue
      b=$(basename "$d")
      P=$d/slang.uhdm
      Q=$PATCHED/$mode/$b/slang.uhdm
      C=$d/cmds.txt
      G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" 2>/dev/null | head -1)
      [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
      # A row that is SLANG_REJECT in the committed baseline produces NO
      # slang.uhdm on EITHER side (Scoreboard/testflags: `use of undeclared
      # identifier 'my_scoreboard'`).  That is the documented state, not a
      # regression, and reporting it as FATAL trains the reader to ignore the
      # instrument -- the campaign's own "cited guard" failure mode.  An
      # ASYMMETRY (one side has a database and the other does not) stays FATAL,
      # because that IS a regression and is exactly what this could hide.
      if [ ! -f "$P" ] && [ ! -f "$Q" ]; then
        printf '%-12s %-9s NO-DB-BOTH-SIDES (SLANG_REJECT row; nothing to compare)\n' \
               "$n" "$mode"
        continue
      fi
      if [ -z "$G" ] || [ ! -f "$G" ] || [ ! -f "$P" ] || [ ! -f "$Q" ]; then
        printf '%-12s %-9s FATAL-ASYMMETRY pris=%s patched=%s golden=%s\n' \
               "$n" "$mode" "$([ -f "$P" ] && echo y || echo N)" \
               "$([ -f "$Q" ] && echo y || echo N)" "${G:-none}"
        rc=4; continue
      fi
      db=SAME-DB; cmp -s "$P" "$Q" || db=DB-MOVED
      "$CMP" "$G" "$P" > "$OUT/$n.$mode.pris.cmp" 2>&1
      "$CMP" "$G" "$Q" > "$OUT/$n.$mode.patched.cmp" 2>&1
      lp=$(wc -l < "$OUT/$n.$mode.pris.cmp")
      lq=$(wc -l < "$OUT/$n.$mode.patched.cmp")
      if cmp -s "$OUT/$n.$mode.pris.cmp" "$OUT/$n.$mode.patched.cmp"; then
        v="CMP-BYTE-IDENTICAL"
      else
        v="CMP-CHANGED"; rc=5
      fi
      printf '%-12s %-9s %-9s pris=%-9s patched=%-9s %s\n' \
             "$n" "$mode" "$db" "$lp" "$lq" "$v"
    done
  done
done
[ "$rc" = 0 ] && echo "WALL HELD: every row's cmp output byte-identical" \
              || echo "WALL ATTENTION rc=$rc -- read the rows above"
exit $rc

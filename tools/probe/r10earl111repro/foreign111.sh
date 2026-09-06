#!/usr/bin/env bash
# r10earl111 -- THE FOREIGN-ARM SCORER.  The wide boundary says WHICH earlier
# pass's arm moved; this says WHETHER IT MOVED TOWARD GOLDEN, which is the only
# question that decides a landing (RESUME.md section 7).
#
# MEASUREMENT ONLY.  The official uhdm-cmp is the sole acceptance judge; the
# cen111 census is printed beside it, never instead of it.
#
#   PATCHED_BIN=<bin> PRISTINE_BIN=<bin> bash foreign111.sh <outdir> <arm.sv> ...
#
# GUARDS:
#   * NO -top is passed: a foreign arm's top is its own business and guessing
#     one changes what is elaborated.  The wide boundary ran them the same way,
#     so this scores exactly the run that flagged them;
#   * every producer's rc is printed; a missing database prints REJECT and is
#     COUNTED, never silently skipped;
#   * the census rc (CENRC) is asserted, so a census that restored nothing
#     cannot read as "nothing differs";
#   * children get </dev/null.
set -u
PAT=${PATCHED_BIN:?set PATCHED_BIN}; PRIS=${PRISTINE_BIN:?set PRISTINE_BIN}
HERE=$(cd "$(dirname "$0")" && pwd)
CEN=$HERE/cen111
SL=$HOME/git-repos/Surelog/build/bin/surelog
CMP=$HOME/git-repos/UHDM/build/bin/uhdm-cmp
OUT=${1:?outdir}; shift
mkdir -p "$OUT"
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
printf '%-34s %-6s %5s %5s %5s %10s %10s %s\n' ARM VIEW SLRC PRC ARC "PRIS c/h" "PATCH c/h" VERDICT
for f in "$@"; do
  [ -f "$f" ] || { echo "MISSING $f"; continue; }
  arm=$(echo "${f#*/tools/probe/}" | tr '/' '_'); arm=${arm%.sv}
  for view in plain elab; do
    case $view in plain) SLF="-parse"; SUF="";; elab) SLF="-parse -elabuhdm"; SUF="--elabuhdm";; esac
    d="$OUT/${arm}_${view}"; mkdir -p "$d"; rm -rf "$d/sl"
    cp "$f" "$d/"; b=$(basename "$f")
    ( cd "$d" && $SL $SLF -nobuiltin -nocache -mt 0 -mp 0 -d uhdm -o sl "$b" > sl.log 2>&1 </dev/null ); slrc=$?
    G=$(find "$d/sl" -name '*.uhdm' 2>/dev/null | head -1)
    ( cd "$d" && "$PRIS" $SUF "$b" --nobuiltin -o pris.uhdm    > p.log 2>&1 </dev/null ); prc=$?
    ( cd "$d" && "$PAT"  $SUF "$b" --nobuiltin -o patched.uhdm > a.log 2>&1 </dev/null ); arc=$?
    if [ -z "${G:-}" ] || [ ! -f "$G" ] || [ ! -f "$d/pris.uhdm" ] || [ ! -f "$d/patched.uhdm" ]; then
      printf '%-34s %-6s %5s %5s %5s %10s %10s %s\n' "$arm" "$view" "$slrc" "$prc" "$arc" - - REJECT
      continue
    fi
    "$CMP" "$G" "$d/pris.uhdm"    > "$d/pris.cmp" 2>&1
    "$CMP" "$G" "$d/patched.uhdm" > "$d/patch.cmp" 2>&1
    pc=$(wc -l < "$d/pris.cmp");  ph=$(grep -c '^LHS:' "$d/pris.cmp"; true)
    ac=$(wc -l < "$d/patch.cmp"); ah=$(grep -c '^LHS:' "$d/patch.cmp"; true)
    v=SAME
    if [ "$ac" -lt "$pc" ]; then v=TOWARD-GOLDEN
    elif [ "$ac" -gt "$pc" ]; then v=LINES-UP-CHECK-HEAD
    elif ! cmp -s "$d/pris.cmp" "$d/patch.cmp"; then v=CMP-TEXT-CHANGED
    fi
    printf '%-34s %-6s %5s %5s %5s %10s %10s %s\n' "$arm" "$view" "$slrc" "$prc" "$arc" "$pc/$ph" "$ac/$ah" "$v"
    for c in gold:$G pris:$d/pris.uhdm patch:$d/patched.uhdm; do
      "$CEN" "${c#*:}" "${arm}_${view}" > "$d/cen.${c%%:*}.txt" 2>&1
      tail -1 "$d/cen.${c%%:*}.txt" | grep -q '^CENRC 0$' || echo "  CENRC-BAD $arm $view ${c%%:*}"
    done
    python3 "$HERE/cen111.py" "$d/cen.gold.txt" "$d/cen.pris.txt" "$d/cen.patch.txt" > "$d/score.txt" 2>&1
    sed -n 's/^/  /p' "$d/score.txt" | grep -E 'STRICT|SHAPE ' || true
  done
done

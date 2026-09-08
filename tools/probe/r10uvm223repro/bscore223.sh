#!/usr/bin/env bash
# r10uvm223 — RE-SCORE A MOVED BOUNDARY ARM AGAINST GOLDEN.  MEASUREMENT ONLY.
#
# The wide boundary says WHICH arms moved; it cannot say whether they moved
# toward golden.  This compiles each named arm with the CANONICAL golden-side
# Surelog (the one scripts/verify_golden.py names) and runs the OFFICIAL
# uhdm-cmp golden-vs-pristine and golden-vs-patched, printing both line counts
# and both head counts so the verdict is read off the judge, not off a hash.
# Every rc is printed; an arm whose compile fails on either side is printed
# loudly, because an arm that does not build teaches error recovery.
#
#   usage: bscore223.sh <probe-tree> <scratch> <binPRIS> <binPAT> <rel> [rel ...]
set -u
TREE=${1:?probe tree}; SCR=${2:?scratch}; A=${3:?pristine bin}; B=${4:?patched bin}
shift 4
SL=${SL:-$HOME/git-repos/Surelog/build/bin/surelog}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
[ -x "$A" ] && [ -x "$B" ] || { echo "FATAL: missing binary"; exit 3; }
[ -x "$SL" ] || { echo "FATAL: no surelog at $SL"; exit 3; }
[ -x "$CMP" ] || { echo "FATAL: no uhdm-cmp at $CMP"; exit 3; }
mkdir -p "$SCR" || exit 1
printf "%-46s %-5s %9s %6s %9s %6s  %s\n" ARM VIEW PRIS_LINES HEADS PAT_LINES HEADS VERDICT
for rel in "$@"; do
  src=$TREE/$rel
  [ -f "$src" ] || { echo "FATAL: no arm $src"; exit 3; }
  key=$(echo "$rel" | sed 's|^\./||; s|/|__|g; s|\.sv$||')
  d=$SCR/$key; mkdir -p "$d/g" || exit 1
  ( cd "$d/g" && "$SL" -parse -nobuiltin -nocache -sv "$src" > sl.log 2>&1 ); grc=$?
  G=$d/g/slpp_all/surelog.uhdm
  if [ "$grc" != 0 ] || [ ! -f "$G" ]; then
    printf "%-46s %-5s %9s %6s %9s %6s  %s\n" "$rel" - - - - - \
      "SURELOG rc=$grc — ERROR-RECOVERY ARM, no golden"
    continue
  fi
  for ev in def elab; do
    ex=""; [ "$ev" = elab ] && ex="--elabuhdm"
    ( cd "$(dirname "$src")" && "$A" $ex "$(basename "$src")" -o "$d/a.$ev.uhdm" > "$d/a.$ev.log" 2>&1 </dev/null ); arc=$?
    ( cd "$(dirname "$src")" && "$B" $ex "$(basename "$src")" -o "$d/b.$ev.uhdm" > "$d/b.$ev.log" 2>&1 </dev/null ); brc=$?
    if [ ! -f "$d/a.$ev.uhdm" ] || [ ! -f "$d/b.$ev.uhdm" ]; then
      printf "%-46s %-5s %9s %6s %9s %6s  %s\n" "$rel" "$ev" - - - - \
        "NO DATABASE rcA=$arc rcB=$brc"
      continue
    fi
    "$CMP" "$G" "$d/a.$ev.uhdm" > "$d/a.$ev.cmp" 2>&1; pc=$?
    "$CMP" "$G" "$d/b.$ev.uhdm" > "$d/b.$ev.cmp" 2>&1; qc=$?
    al=$(wc -l < "$d/a.$ev.cmp"); ah=$(grep -c '^LHS:' "$d/a.$ev.cmp"); true
    bl=$(wc -l < "$d/b.$ev.cmp"); bh=$(grep -c '^LHS:' "$d/b.$ev.cmp"); true
    v=UNCHANGED
    [ "$bl" -lt "$al" ] && v=TOWARD-GOLDEN
    [ "$bl" -gt "$al" ] && v="LONGER — READ THE HEAD (a NEW head object is not a regression)"
    [ "$al" = "$bl" ] && ! cmp -s "$d/a.$ev.cmp" "$d/b.$ev.cmp" && v="SAME LENGTH, DIFFERENT HEAD — READ IT"
    printf "%-46s %-5s %9s %6s %9s %6s  %s rc=%s/%s\n" \
      "$rel" "$ev" "$al" "$ah" "$bl" "$bh" "$v" "$pc" "$qc"
  done
done

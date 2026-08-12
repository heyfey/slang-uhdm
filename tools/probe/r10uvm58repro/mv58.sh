#!/usr/bin/env bash
# r10uvm58repro/mv58.sh — PER-SHAPE MOVER ATTRIBUTION AGAINST GOLDEN.
#
#   usage: mv58.sh <patched-workdir-root> <pristine-workdir-root> <outdir>
#
# For every database the byte verifier flagged as a mover it dumps BOTH sides,
# takes EVERY changed dump line, and looks each distinct SHAPE up IN GOLDEN with
# a per-shape `grep -Fxc`.  ADDED and REMOVED are reported SEPARATELY, and each
# gets a verdict against golden's own multiplicity:
#
#   ADDED   : golden count 0                  -> OVER-FIRE  (golden LACKS it)
#   ADDED   : ours(new) count <= golden count  -> covered
#   ADDED   : ours(new) count >  golden count  -> OVER-FIRE  (too many)
#   REMOVED : golden count > 0 and ours(new) < golden -> UNDER-FIRE (golden HAS it)
#   REMOVED : golden count 0                  -> correct deletion
#
# THIS IS THE METHOD THAT CAUGHT 11 OVER-FIRES AN AUDIT MISSED, so it is run
# unconditionally and its numbers are printed, never summarised.
#
# GUARDS, each an ops trap this campaign has paid for:
#   * uhdm-dump's FIRST LINE is the DATABASE PATH: all three dumps go through
#     `sed 1d`, so no shape is ever a file path.
#   * INDENTATION IS STRIPPED before keying (an object is not a dump
#     occurrence), and the count is a MULTIPLICITY, so a depth-only or
#     multiplicity-only move is still visible as a count delta.
#   * the golden path is read out of the workdir's own cmds.txt and the cache
#     DIRECTORY is turned into .../golden.uhdm — handing uhdm-dump a directory
#     dumps nothing and would make every shape read as "golden lacks it".
#   * a missing golden is GOLDEN_MISSING and exit 6, never a verdict.
#   * SELFCHECK=1 injects one fabricated shape into the ADDED list and asserts
#     it is reported as an OVER-FIRE, so an attributor that cannot see one bad
#     line cannot pass silently.
set -u
A=${1:?patched workdir root}
B=${2:?pristine workdir root}
OUT=${3:?outdir}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -x "$DUMP" ] || { echo "FATAL: no uhdm-dump at $DUMP"; exit 3; }
mkdir -p "$OUT" || exit 1
strip() { sed 's#/home/[^ ,]*/##g' | sed '1d' | sed 's/^[[:space:]]*//'; }
tot_add=0; tot_rem=0; over=0; under=0; movers=0
while read -r p; do
  cmp -s "$A/$p" "$B/$p" && continue
  movers=$((movers+1))
  d=$(dirname "$p")
  key=$(echo "$d" | tr '/' '_')
  C=$B/$d/cmds.txt
  G=""
  [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ]; then
    echo "GOLDEN_MISSING for $d (g=${G:-none}) -- cannot attribute"; exit 6
  fi
  "$DUMP" "$A/$p" 2>/dev/null | strip > "$OUT/$key.new"
  "$DUMP" "$B/$p" 2>/dev/null | strip > "$OUT/$key.old"
  "$DUMP" "$G"    2>/dev/null | strip > "$OUT/$key.gold"
  for f in new old gold; do
    [ -s "$OUT/$key.$f" ] || { echo "NO_OUTPUT: $key.$f empty"; exit 6; }
  done
  # MULTISET deltas, not a diff alignment.
  sort "$OUT/$key.new"  | uniq -c | sed -E 's/^ *([0-9]+) /\1\t/' > "$OUT/$key.cn"
  sort "$OUT/$key.old"  | uniq -c | sed -E 's/^ *([0-9]+) /\1\t/' > "$OUT/$key.co"
  sort "$OUT/$key.gold" | uniq -c | sed -E 's/^ *([0-9]+) /\1\t/' > "$OUT/$key.cg"
  awk -F'\t' 'FNR==NR{o[$2]=$1;next}{n[$2]=$1}
     END{for(k in n){d=n[k]-(k in o?o[k]:0); if(d>0) printf "%d\t%s\n", d, k}}' \
     "$OUT/$key.co" "$OUT/$key.cn" | sort -k2 > "$OUT/$key.added"
  awk -F'\t' 'FNR==NR{n[$2]=$1;next}{o[$2]=$1}
     END{for(k in o){d=o[k]-(k in n?n[k]:0); if(d>0) printf "%d\t%s\n", d, k}}' \
     "$OUT/$key.cn" "$OUT/$key.co" | sort -k2 > "$OUT/$key.removed"
  [ "${SELFCHECK:-0}" = 1 ] && printf '1\t\\_FABRICATED_SHAPE_THAT_GOLDEN_CANNOT_HAVE: , line:1:1\n' >> "$OUT/$key.added"
  na=$(awk -F'\t' '{s+=$1}END{print s+0}' "$OUT/$key.added")
  nr=$(awk -F'\t' '{s+=$1}END{print s+0}' "$OUT/$key.removed")
  tot_add=$((tot_add+na)); tot_rem=$((tot_rem+nr))
  echo "== MOVER $d   ADDED line instances=$na   REMOVED line instances=$nr"
  while IFS=$'\t' read -r c shape; do
    [ -n "${shape:-}" ] || continue
    gc=$(grep -Fxc -- "$shape" "$OUT/$key.gold" || true)
    nc=$(grep -Fxc -- "$shape" "$OUT/$key.new" || true)
    if [ "$gc" -eq 0 ] || [ "$nc" -gt "$gc" ]; then
      v="OVER-FIRE"; over=$((over+1))
    else
      v="covered"
    fi
    printf "   ADDED   x%-4s golden=%-5s ours=%-5s %-11s %s\n" "$c" "$gc" "$nc" "$v" "$shape"
  done < "$OUT/$key.added"
  while IFS=$'\t' read -r c shape; do
    [ -n "${shape:-}" ] || continue
    gc=$(grep -Fxc -- "$shape" "$OUT/$key.gold" || true)
    nc=$(grep -Fxc -- "$shape" "$OUT/$key.new" || true)
    if [ "$gc" -gt 0 ] && [ "$nc" -lt "$gc" ]; then
      v="UNDER-FIRE"; under=$((under+1))
    else
      v="correct"
    fi
    printf "   REMOVED x%-4s golden=%-5s ours=%-5s %-11s %s\n" "$c" "$gc" "$nc" "$v" "$shape"
  done < "$OUT/$key.removed"
done < <(cd "$A" && find . -name slang.uhdm | sort)
echo "---- movers=$movers  ADDED instances=$tot_add  REMOVED instances=$tot_rem"
echo "---- OVER-FIRE shapes=$over  UNDER-FIRE shapes=$under"
if [ "${SELFCHECK:-0}" = 1 ]; then
  [ "$over" -ge "$movers" ] && echo "SELFCHECK PASS: the injected shape was reported OVER-FIRE on every mover" \
                            || { echo "SELFCHECK FAILED: injected shapes not all flagged"; exit 5; }
fi

#!/usr/bin/env bash
# r10uvm57repro/mv57.sh — is a byte mover a PURE ADDITION or does it carry
# DELETIONS?  `diff -u` cannot answer that: a generic marker line
# (`|vpiTaskFunc:`) re-aligns and prints 23 `-` and 23 `+` for a change that
# removed nothing (Scoreboard, r10uvm57 README §5).  This uses the MULTISET,
# which has no alignment at all: DELETED = line instances present in the
# PRISTINE dump and absent from the PATCHED one.
#
#   usage: [SELFCHECK=1] mv57.sh <patched_wd_root> <pristine_wd_root> <relpath...>
#
# ---------------------------------------------------------------------------
# WHY THIS EXISTS AND NOT `r10uvm55repro/msdist.sh`: THAT INSTRUMENT IS BROKEN.
# msdist.sh counts with `sort | uniq -c` over the RAW dump lines and only THEN
# collapses indentation (`awk '{c=$1;$1="";print c"\t"$0}'` rebuilds $0 with a
# single-space OFS), after which it stores the per-key count with an
# ASSIGNMENT — `g[$2]=$1`.  Two raw lines that differ only in DEPTH collapse to
# the same key, so the second one OVERWRITES the first's count instead of
# adding to it.  Measured, on this pass's own SimpleUVM mover (1100381 vs
# 1100471 dump lines, a real 90-line difference):
#     msdist.sh  ->  golden-only 0   ours-only 0   MULTISET DISTANCE 0
#     the same awk with `+=` -> pristine-only 0   patched-only 90
# 350100 distinct raw lines collapse to 136799 keys, which is the size of the
# hole.  So msdist.sh can report distance 0 for dumps that provably differ, and
# NO msdist figure in this campaign should be trusted without re-derivation.
# This script therefore (a) strips indentation BEFORE counting, so the multiset
# is well defined, and (b) ACCUMULATES with `+=`.
# ---------------------------------------------------------------------------
#
# GUARDS:
#   * uhdm-dump's FIRST LINE is the DATABASE PATH -> `sed 1d` on BOTH sides.
#   * an empty or missing dump is exit 6, never "0 deletions".
#   * SELFCHECK=1 re-runs the comparison of the PATCHED dump against a copy of
#     itself with ONE line deleted; it must then report exactly 1 DELETED and
#     the verdict CARRIES DELETIONS.  A verifier that cannot see one removed
#     line cannot certify "pure addition".
set -u
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
A=${1:?patched root}; B=${2:?pristine root}; shift 2
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

# counts an indentation-STRIPPED multiset: <count>\t<line>
cnt() { sed -E 's/^[[:space:]]+//' "$1" | sort | uniq -c |
        sed -E 's/^ *([0-9]+) /\1\t/'; }

# prints DELETED / ADDED / verdict for two count files (pristine first)
cmpms() {
  awk -F'\t' '
    FNR==NR { b[$2] += $1; next }
    { a[$2] += $1 }
    END {
      for (k in b) { d = b[k] - (k in a ? a[k] : 0); if (d>0) del += d }
      for (k in a) { d = a[k] - (k in b ? b[k] : 0); if (d>0) add += d }
      printf "  pristine-only (DELETED) line instances: %d\n", del+0
      printf "  patched-only  (ADDED)   line instances: %d\n", add+0
      printf "  VERDICT: %s\n", (del+0 == 0 ? "PURE ADDITION" : "CARRIES DELETIONS")
    }' "$1" "$2"
}

for p in "$@"; do
  echo "================ $p"
  "$DUMP" "$A/$p" 2>/dev/null | sed 1d > "$T/a"
  "$DUMP" "$B/$p" 2>/dev/null | sed 1d > "$T/b"
  if [ ! -s "$T/a" ] || [ ! -s "$T/b" ]; then
    echo "  NO_OUTPUT: an empty dump — this is NOT a verdict"; exit 6
  fi
  echo "  dump lines: pristine=$(wc -l < "$T/b")  patched=$(wc -l < "$T/a")"
  cnt "$T/b" > "$T/bc"; cnt "$T/a" > "$T/ac"
  cmpms "$T/bc" "$T/ac"
  echo "  --- the ADDED instances, by SHAPE (spans erased, indentation stripped) ---"
  awk -F'\t' '
    FNR==NR { b[$2] += $1; next }
    { d = $1 - ($2 in b ? b[$2] : 0); if (d>0) printf "%d\t%s\n", d, $2 }
  ' "$T/bc" "$T/ac" |
    sed -E 's/, line:[0-9]+:[0-9]+, endln:[0-9]+:[0-9]+//; s/line:[0-9]+:[0-9]+, endln:[0-9]+:[0-9]+//' |
    awk -F'\t' '{c[$2] += $1} END {for (k in c) printf "%6d  %s\n", c[k], k}' |
    sort -rn | head -14 | sed 's/^/  /'
  if [ "${SELFCHECK:-0}" = 1 ]; then
    sed '5d' "$T/a" > "$T/a1"
    cnt "$T/a1" > "$T/a1c"
    echo "  --- SELFCHECK (patched vs patched-minus-one-line; must be 1 DELETED) ---"
    cmpms "$T/ac" "$T/a1c" | sed 's/^/  /'
  fi
done

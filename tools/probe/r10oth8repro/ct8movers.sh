#!/usr/bin/env bash
# r10oth8 — MOVER ATTRIBUTION: for every byte mover the verifier named, prove the
# change is § arrayVarSignedWritten8 and nothing else.
#
#   usage: ct8movers.sh <patched-workdir-root> <pristine-workdir-root> [mode/test-dir]...
#          (with no list, it re-derives the movers itself with `cmp -s`)
#
# BOTH SIDES ARE OURS.  This is NOT a golden comparison: it diffs OUR pristine
# dump against OUR patched dump, so every reported line is a byte this pass moved.
# "A fix that reaches nothing measures zero and reads as a refutation" — this is
# the proof the code ran, and the count of the sites it ran at.
#
# It reports, per mover:
#   * total dump CONTENT lines changed (uhdm-dump line 1 = the DATABASE PATH is
#     stripped with `sed 1d`; `diff -u`'s own `---`/`+++` header is excluded —
#     TWO separate traps, both handled);
#   * `+ |vpiSigned` and `- |vpiSigned` LINE counts;
#   * whether EVERY changed line is a `|vpiSigned:` line, printed as
#     ONLY-VPISIGNED or MIXED.  MIXED is not a failure by itself, but it means
#     the mover cannot be attributed to this law alone and must be read by hand.
# A database missing on either side prints UNMEASURED for that mover.
set -u
A=${1:?patched workdir root}
B=${2:?pristine workdir root}
shift 2
UD=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
[ -d "$A" ] && [ -d "$B" ] || { echo NO_WORKDIR; exit 6; }
list=$(mktemp)
if [ "$#" -gt 0 ]; then
  printf '%s\n' "$@" > "$list"
else
  (cd "$A" && find . -name slang.uhdm | sort) | while read -r p; do
    cmp -s "$A/$p" "$B/$p" || dirname "$p" | sed 's#^\./##'
  done > "$list"
fi
n=$(wc -l < "$list")
echo "movers to attribute: $n"
while read -r d; do
  pa="$A/$d/slang.uhdm"; pb="$B/$d/slang.uhdm"
  if [ ! -f "$pa" ] || [ ! -f "$pb" ]; then echo "  $d: UNMEASURED"; continue; fi
  w=$(mktemp -d)
  "$UD" "$pb" 2>/dev/null | sed 1d > "$w/pre.dump"    # ours, pristine
  "$UD" "$pa" 2>/dev/null | sed 1d > "$w/post.dump"   # ours, patched
  if [ ! -s "$w/pre.dump" ] || [ ! -s "$w/post.dump" ]; then
    echo "  $d: UNMEASURED (empty dump)"; rm -rf "$w"; continue
  fi
  diff -u "$w/pre.dump" "$w/post.dump" > "$w/d.diff" || true
  tot=$(grep -E '^[-+]' "$w/d.diff" | grep -vcE '^(---|\+\+\+) ')
  add=$(grep -cE '^\+.*\|vpiSigned:' "$w/d.diff" || true)
  del=$(grep -cE '^-.*\|vpiSigned:' "$w/d.diff" || true)
  other=$(grep -E '^[-+]' "$w/d.diff" | grep -vE '^(---|\+\+\+) ' |
          grep -vcE '\|vpiSigned:' || true)
  verdict=ONLY-VPISIGNED
  [ "$other" != 0 ] && verdict="MIXED ($other non-vpiSigned lines)"
  printf '  %-44s content=%-4s +vpiSigned=%-4s -vpiSigned=%-4s %s\n' \
         "$d" "$tot" "$add" "$del" "$verdict"
  [ "$other" != 0 ] && grep -E '^[-+]' "$w/d.diff" | grep -vE '^(---|\+\+\+) ' |
    grep -vE '\|vpiSigned:' | head -6 | sed 's/^/      /'
  rm -rf "$w"
done < "$list"
rm -f "$list"

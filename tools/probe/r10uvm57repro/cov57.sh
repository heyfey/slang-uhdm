#!/usr/bin/env bash
# r10uvm57repro/cov57.sh — THE ONLY ATTRIBUTABLE MOVER TEST: is every line this
# pass ADDED a line GOLDEN ALSO HAS?
#
# "0 rows moved" and "pure addition" both say nothing about whether the addition
# is CORRECT.  This takes the multiset of line instances the patched dump has
# and the pristine one does not, and checks each one against GOLDEN's own
# multiset.  A line added that golden does not carry (or carries fewer times) is
# an OVER-FIRE and is printed by name.
#
#   usage: cov57.sh <patched_wd_root> <pristine_wd_root> <mode/testdir>
#          e.g.   cov57.sh /tmp/fin_wd /tmp/pris_wd default/SimpleUVM-1dc93a62
#
# LHS is ALWAYS golden(Surelog), RHS is ALWAYS ours — golden here is resolved
# out of the row's OWN cmds.txt (`golden cache hit <dir>`), so the script cannot
# silently compare against the wrong golden; a missing one is exit 6.
#
# GUARDS:
#   * uhdm-dump's FIRST LINE is the DATABASE PATH -> `sed 1d` on all THREE dumps.
#   * indentation is stripped BEFORE counting and counts ACCUMULATE with `+=`
#     (see mv57.sh's header for the msdist.sh bug this avoids).
#   * SELFCHECK=1 injects a line golden cannot have and requires it to be
#     reported as NOT-IN-GOLDEN.  A coverage test that cannot fail is not a test.
set -u
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
A=${1:?patched wd root}; B=${2:?pristine wd root}; R=${3:?mode/testdir}
PA=$A/$R/slang.uhdm; PB=$B/$R/slang.uhdm; C=$A/$R/cmds.txt
for f in "$PA" "$PB" "$C"; do
  [ -f "$f" ] || { echo "FATAL: missing $f"; exit 6; }
done
G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
[ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
[ -n "$G" ] && [ -f "$G" ] || { echo "FATAL: no golden resolved from $C"; exit 6; }
echo "ROW=$R"
echo "GOLDEN=$G"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
cnt() { sed -E 's/^[[:space:]]+//' "$1" | sort | uniq -c |
        sed -E 's/^ *([0-9]+) /\1\t/'; }
"$DUMP" "$PA" 2>/dev/null | sed 1d > "$T/a"
"$DUMP" "$PB" 2>/dev/null | sed 1d > "$T/b"
"$DUMP" "$G"  2>/dev/null | sed 1d > "$T/g"
for f in a b g; do
  [ -s "$T/$f" ] || { echo "NO_OUTPUT: empty dump ($f)"; exit 6; }
done
[ "${SELFCHECK:-0}" = 1 ] &&
  echo '\_ZZZ_NOT_A_REAL_UHDM_LINE_57: (control), line:1:1, endln:1:2' >> "$T/a"
cnt "$T/a" > "$T/ac"; cnt "$T/b" > "$T/bc"; cnt "$T/g" > "$T/gc"
printf "dump lines: golden=%s pristine=%s patched=%s\n" \
  "$(wc -l < "$T/g")" "$(wc -l < "$T/b")" "$(wc -l < "$T/a")"
printf "|vpiActual: golden=%s pristine=%s patched=%s\n" \
  "$(grep -c '|vpiActual:' "$T/g")" "$(grep -c '|vpiActual:' "$T/b")" \
  "$(grep -c '|vpiActual:' "$T/a")"
awk -F'\t' 'FNR==NR{b[$2]+=$1;next}{d=$1-($2 in b?b[$2]:0); if(d>0) print d"\t"$2}' \
  "$T/bc" "$T/ac" > "$T/added"
# REMOVED: for each shape the PRISTINE dump carries, how many instances the
# PATCHED one is missing.  (This line had the operands the wrong way round on
# its first run and printed the ADDED count again — fixed, and the fix is
# visible because mv57.sh independently reports DELETED=0 for the same rows.)
awk -F'\t' 'FNR==NR{a[$2]+=$1;next}{d=$1-($2 in a?a[$2]:0); if(d>0) print d"\t"$2}' \
  "$T/ac" "$T/bc" > "$T/removed"
echo "ADDED distinct shapes=$(wc -l < "$T/added")  instances=$(awk -F'\t' '{s+=$1}END{print s+0}' "$T/added")"
echo "REMOVED instances=$(awk -F'\t' '{s+=$1}END{print s+0}' "$T/removed")"
awk -F'\t' '
  FNR==NR { g[$2] += $1; next }
  { if (($2 in g) && g[$2] >= $1) ok += $1;
    else { bad += $1; print "  OVER-FIRE (not in golden, x"$1"): "$2 } }
  END { printf "COVERED BY GOLDEN=%d  NOT COVERED=%d\n", ok+0, bad+0;
        exit (bad+0 > 0 ? 5 : 0) }' "$T/gc" "$T/added"

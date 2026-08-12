#!/bin/bash
# r10svs5repro/census.sh — THE BLAST-RADIUS CENSUS for § vifClockingPathComponent5.
#
# The law fires on a reference written `<handle>.<X>.<leaf>` where <handle> is a
# VIRTUAL INTERFACE and <X> is a scope INSIDE the interface (a named CLOCKING
# BLOCK, or a nested interface INSTANCE).  So the census is:
#   1. collect every NAMED CLOCKING BLOCK declared in the corpora.  The
#      declaration is `clocking <name> @(...)` or `clocking <name>;` — matching
#      bare `clocking <word>` also picks up ENGLISH PROSE from comments
#      ("clocking blocks", "clocking block below"), which is why the `@`/`;`
#      lookahead is part of the pattern.
#   2. grep for `.<name>.` uses;
#   3. map each hit FILE to the TEST it belongs to (the directory under
#      tests/), and intersect with the tests that actually have rows in
#      results/golden_surelog.csv / golden_uhdm2rtlil.csv, since a source site in
#      a file no corpus test compiles cannot move anything.
#
# WHY IT IS RUN OVER third_party/UVM TOO: r10svs4's prediction was 1 mover and
# the verifier found 9, because its grep covered `Surelog/tests`,
# `Surelog/third_party/tests` and `uhdm2rtlil/test` and OMITTED
# `Surelog/third_party/UVM`, which the four UVM tests compile in.  A source grep
# over test directories is not a blast radius when tests vendor a library.
#
#   usage: census.sh [-v]      (-v also prints every use site)
set -u
V=${1:-}
SUR=$HOME/git-repos/Surelog
ROOTS="$SUR/tests $SUR/third_party/tests $SUR/third_party/UVM $HOME/git-repos/uhdm2rtlil/test"
RES=$(cd "$(dirname "$0")"/../../.. && pwd)/results
T=$(mktemp -d)
for r in $ROOTS; do [ -d "$r" ] || { echo "MISSING ROOT: $r"; exit 6; }; done
[ -f "$RES/golden_surelog.csv" ] || { echo "MISSING results"; exit 6; }

grep -rhoE --include=*.sv --include=*.svh --include=*.v --include=*.vh \
     '(^|[^[:alnum:]_])clocking[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*[@;]' $ROOTS 2>/dev/null |
  sed -E 's/[[:space:]]*[@;]$//' | grep -oE '[A-Za-z0-9_]+$' | sort -u > "$T/cbnames"
echo "== NAMED CLOCKING BLOCKS declared in the corpora: $(wc -l < "$T/cbnames")"
tr '\n' ' ' < "$T/cbnames"; echo; echo

: > "$T/uses"
while read -r nm; do
    grep -rnE --include=*.sv --include=*.svh --include=*.v --include=*.vh \
        "\.${nm}\.[A-Za-z_]" $ROOTS 2>/dev/null | sed "s#^#${nm}|#" >> "$T/uses"
done < "$T/cbnames"
# NOTE: this line used to be written with BACKQUOTES inside a double-quoted echo
# (`.<cb>.<id>`), which bash read as a COMMAND SUBSTITUTION and printed a syntax
# error in the middle of the census output. Single quotes, deliberately.
echo '-- total .<cb>.<id> use sites:' "$(wc -l < "$T/uses")"
echo

# TEST attribution: tests/<Name>/... and third_party/tests/<Name>/... are tests;
# everything under third_party/UVM is the vendored library every UVM-compiling
# test pulls in, and is reported as one bucket.
awk -F'|' '{print $2}' "$T/uses" | awk -F: '{print $1}' |
  sed -E "s#^$SUR/third_party/UVM/.*#<UVM-LIBRARY>#; \
          s#^$SUR/tests/([^/]*)/.*#\1#; \
          s#^$SUR/third_party/tests/([^/]*)/.*#\1#; \
          s#^$HOME/git-repos/uhdm2rtlil/test/([^/]*)/.*#u2r:\1#" |
  sort | uniq -c | sort -rn > "$T/bytest"
echo "== use sites per TEST-directory (not yet intersected with the row sets)"
cat "$T/bytest"
echo
echo "== INTERSECTED with the corpora that actually have ROWS"
while read -r n t; do
    case "$t" in
      '<UVM-LIBRARY>') echo "  $n  $t  (reaches every UVM-compiling test)"; continue;;
      u2r:*) nm=${t#u2r:}
             if grep -qE "^$nm," "$RES/golden_uhdm2rtlil.csv" 2>/dev/null; then
                 echo "  $n  $t  ROW=yes"; else echo "  $n  $t  ROW=no"; fi; continue;;
    esac
    if grep -qE "^$t," "$RES/golden_surelog.csv"; then
        st=$(grep -E "^$t,default," "$RES/golden_surelog.csv" | head -1 | cut -d, -f3)
        echo "  $n  $t  ROW=yes  status=$st"
    else
        echo "  $n  $t  ROW=no"
    fi
done < "$T/bytest"
if [ "$V" = "-v" ]; then echo; echo "== the SITES"; cat "$T/uses"; fi
rm -rf "$T"

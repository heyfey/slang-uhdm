#!/bin/bash
# r10uvm160 — THE WHOLE-DUMP, PATH-NORMALISED, ORDER-BLIND DIFF.
# MEASUREMENT ONLY; the official uhdm-cmp is the judge.
#
#   usage: dumpdiff160.sh <pris workdir> <pat workdir> <rel> [<rel> ...]
#
# Scoreboard/default is a ~50/50 COIN per invocation (RESUME.md §9), so ORDER-
# BLIND (both dumps sorted) is the only sound attribution.  Dump paths embed the
# workdir, so both sides are normalised before any comparison.  For each row it
# prints
#   * PRIS->PAT   the lines this pass ADDED and DELETED, and
#   * DIST        how many sorted lines differ from GOLDEN before and after —
#                 the number that says TOWARD or AWAY, because a span-keyed
#                 census cannot tell a macro-expansion span apart from a wrong
#                 object.
set -u
A=${1:?pristine workdir}; B=${2:?patched workdir}; shift 2
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
T=$(mktemp -d /tmp/r10uvm160_dd_XXXXXX) || exit 1
norm() { sed -e "s#$A/##g" -e "s#$B/##g" -e 's#/[^ ]*/slang\.uhdm#SLANGDB#g' \
             -e 's#/[^ ]*/golden\.uhdm#GOLDENDB#g' -e 's/, id:[0-9]*//g' \
             -e 's/^[[:space:]]*//' | sort; }
for rel in "$@"; do
  if [ ! -f "$A/$rel/slang.uhdm" ] || [ ! -f "$B/$rel/slang.uhdm" ]; then
    echo "SKIP-NOFILE $rel"; continue
  fi
  G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$A/$rel/cmds.txt" | head -1)
  [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
  if [ -z "$G" ] || [ ! -f "$G" ]; then echo "SKIP-NOFILE $rel (no golden)"; continue; fi
  "$DUMP" "$G"                 2>/dev/null | norm > "$T/g"
  "$DUMP" "$A/$rel/slang.uhdm" 2>/dev/null | norm > "$T/a"
  "$DUMP" "$B/$rel/slang.uhdm" 2>/dev/null | norm > "$T/b"
  add=$(comm -13 "$T/a" "$T/b" | wc -l); del=$(comm -23 "$T/a" "$T/b" | wc -l)
  da=$(comm -3 "$T/g" "$T/a" | wc -l); db=$(comm -3 "$T/g" "$T/b" | wc -l)
  printf '%-34s PRIS->PAT added=%-5s deleted=%-5s   DIST-to-golden pris=%-7s pat=%-7s %s\n' \
     "$rel" "$add" "$del" "$da" "$db" \
     "$([ "$db" -lt "$da" ] && echo TOWARD || { [ "$db" -gt "$da" ] && echo AWAY || echo SAME; })"
  { echo "=== $rel ADDED (pristine -> patched)"; comm -13 "$T/a" "$T/b";
    echo "=== $rel DELETED (pristine -> patched)"; comm -23 "$T/a" "$T/b"; } \
    >> "${DDDETAIL:-/dev/null}"
done
rm -rf "$T"

#!/usr/bin/env bash
# r10uvm119repro/attrib119.sh — ORDER-BLIND ATTRIBUTION of one mover.
# MEASUREMENT ONLY.
#
#   attrib119.sh <pristine-cell-dir> <patched-cell-dir> <tag> <outdir>
#
# Dumps both databases, normalises the workdir out of the text (dump paths
# embed it), SORTS both, and diffs.  Sorting is what makes the read valid on
# Scoreboard/default, which is a ~50/50 ORDER COIN per invocation (RESUME §9):
# an unsorted diff there reads ~92 lines of pure nondeterminism.  Every line
# that survives is then classified as this law's or not.
set -u
P=$1; Q=$2; TAG=$3; OUT=$4
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
mkdir -p "$OUT"
"$DUMP" "$P/slang.uhdm" 2>/dev/null | sed "s#$P/##g; 1s#^[^:]*\.uhdm:#<DB>:#" | LC_ALL=C sort > "$OUT/$TAG.p.srt"
rcp=$?
"$DUMP" "$Q/slang.uhdm" 2>/dev/null | sed "s#$Q/##g; 1s#^[^:]*\.uhdm:#<DB>:#" | LC_ALL=C sort > "$OUT/$TAG.q.srt"
rcq=$?
diff "$OUT/$TAG.p.srt" "$OUT/$TAG.q.srt" > "$OUT/$TAG.orderblind.diff" 2>&1
n=$(grep -c '^[<>]' "$OUT/$TAG.orderblind.diff"); [ -z "$n" ] && n=0
# ATTRIBUTION IS BY SOURCE POSITION, not by keyword.  A keyword test
# ("does the line say randomize?") is WRONG here for the obvious reason: the
# whole point of the law is that the path STOPS saying `randomize`, so the
# renamed header lines, the `|vpiWith:` markers and the new constraint's
# `|vpiParent:` back-reference block all fail such a test while being exactly
# this law's own lines.  The honest test is that every `line:L:C` mentioned
# anywhere in the order-blind diff belongs to one of the source sites the
# PREDICTION named from pristine databases alone.  SITES119 is that list.
SITES119=${SITES119:-'204:|299:|56967:|56980:'}
off=$(grep '^[<>]' "$OUT/$TAG.orderblind.diff" | grep -oE 'line:[0-9]+:' | grep -vE "line:($SITES119)" | sort -u)
noff=$(printf '%s' "$off" | grep -c . ); [ -z "$noff" ] && noff=0
printf '%-24s rc=%d/%d ORDER-BLIND-DIFF=%-6d OFF-SITE-POSITIONS=%d\n' "$TAG" $rcp $rcq $n $noff
if [ "$noff" -gt 0 ]; then
  echo "   -- source positions OUTSIDE the predicted sites:"
  printf '%s\n' "$off" | sed 's/^/   /'
  grep '^[<>]' "$OUT/$TAG.orderblind.diff" | grep -E "$(printf '%s' "$off" | paste -sd'|')" | head -20 | sed 's/^/   /'
fi

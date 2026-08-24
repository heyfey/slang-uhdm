#!/usr/bin/env bash
# r10uvm123 — ORDER-BLIND whole-dump attribution of one mover.  Dumps the
# pristine and patched databases, normalises the workdir out of both, SORTS
# (Scoreboard/default is a per-invocation COIN, so only an order-blind read is
# attributable), and prints the line delta with a per-shape tally.
# LHS IS ALWAYS GOLDEN (used only for the direction score, in score123.py).
# MEASUREMENT ONLY.   usage: attr123.sh <pris-db> <pat-db> <out-prefix>
set -u
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
P=$1; Q=$2; O=$3
"$DUMP" "$P" 2>/dev/null | sed '1d' | sed 's#/tmp/[A-Za-z0-9_]*/##g' | sort > "$O.pris"
"$DUMP" "$Q" 2>/dev/null | sed '1d' | sed 's#/tmp/[A-Za-z0-9_]*/##g' | sort > "$O.pat"
diff "$O.pris" "$O.pat" > "$O.diff"
echo "removed=$(grep -c '^<' "$O.diff"; true) added=$(grep -c '^>' "$O.diff"; true)"

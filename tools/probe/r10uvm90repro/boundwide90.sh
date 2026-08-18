#!/usr/bin/env bash
# r10uvm90 — THE WIDE BOUNDARY GATE.  bound90.sh fences the arm directories the
# standing brief NAMES; this one compiles EVERY arm source in tools/probe (188
# directories, 2303 sources) with BOTH binaries, because this pass's law sits in
# the SHARED `ExpressionKind::NewClass` arm and every `new`/`super.new` cell any
# pass ever wrote is a potential mover.  Same guards as bound90.sh (fd 3 list,
# `</dev/null` children, LISTED asserted against PROCESSED, NO_OUTPUT counted).
#   PRI=<pristine> PAT=<patched> ./boundwide90.sh
set -u
PRI=${PRI:?pristine binary}
PAT=${PAT:?patched binary}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
ROOT=${ROOT:-/tmp/wt_r10uvm90/tools/probe}
WD=${WD:-/tmp/r10uvm90_boundwide}
rm -rf "$WD"; mkdir -p "$WD" || exit 9
LIST=$WD/sources.txt
find "$ROOT" -name '*.sv' | sort > "$LIST"
listed=$(wc -l < "$LIST")
n=0; moved=0; noout=0
exec 3< "$LIST"
while IFS= read -r src <&3; do
    n=$((n+1))
    b=$(printf "%04d_%s_%s" "$n" "$(basename "$(dirname "$src")")" "$(basename "$src" .sv)")
    o=$WD/$b; mkdir -p "$o"; cp "$src" "$o/" || continue
    leaf=$(basename "$src")
    ( cd "$o" && "$PRI" "$leaf" -o pris.uhdm >pris.log 2>&1 </dev/null )
    ( cd "$o" && "$PAT" "$leaf" -o pat.uhdm  >pat.log  2>&1 </dev/null )
    if [ ! -f "$o/pris.uhdm" ] || [ ! -f "$o/pat.uhdm" ]; then
      echo "NO_OUTPUT $b"; noout=$((noout+1)); rm -rf "$o"; continue
    fi
    "$DUMP" "$o/pris.uhdm" 2>/dev/null </dev/null | sed 1d > "$o/pris.dump"
    "$DUMP" "$o/pat.uhdm"  2>/dev/null </dev/null | sed 1d > "$o/pat.dump"
    if ! cmp -s "$o/pris.dump" "$o/pat.dump"; then
      echo "MOVED $b  $(diff "$o/pris.dump" "$o/pat.dump" | grep -cE '^[<>]'; true) dump lines"
      moved=$((moved+1))
    else
      rm -f "$o"/*.uhdm
    fi
done
exec 3<&-
echo "---- WIDE boundary LISTED=$listed PROCESSED=$n  MOVED=$moved  NO_OUTPUT=$noout"
[ "$n" -gt 0 ] || { echo "REFUSING TO REPORT: compiled 0 sources"; exit 4; }
[ "$n" = "$listed" ] || { echo "REFUSING TO REPORT: PROCESSED != LISTED"; exit 4; }

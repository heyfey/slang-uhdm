#!/usr/bin/env bash
# r10uvm90 — MOVER ATTRIBUTION.  For ONE mover row: the three-way `new`/
# `super.new` argument table (golden / pristine / patched) AND a whole-dump
# pristine-vs-patched diff, so every moved dump line is accounted for by name.
# LHS is ALWAYS golden.  MEASUREMENT-ONLY.
#   usage: attr90.sh <patched wd> <pristine wd> <mode/row>
set -u
A=${1:?patched wd}; B=${2:?pristine wd}; R=${3:?mode/row}
CEN=${CEN:-/tmp/r10uvm90_ct90cen}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
HERE=$(cd "$(dirname "$0")" && pwd)
G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$B/$R/cmds.txt" | head -1)
[ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
[ -f "$G" ] || { echo "NO_GOLDEN for $R"; exit 3; }
W=/tmp/r10uvm90_attr_$(echo "$R" | tr / _); rm -rf "$W"; mkdir -p "$W"
"$CEN" "$G" --all 2>/dev/null | sort > "$W/g.cen"
"$CEN" "$B/$R/slang.uhdm" --all 2>/dev/null | sort > "$W/pris.cen"
"$CEN" "$A/$R/slang.uhdm" --all 2>/dev/null | sort > "$W/pat.cen"
echo "== $R : golden vs PRISTINE"
python3 "$HERE/join90.py" "$W/g.cen" "$W/pris.cen" | tail -1
echo "== $R : golden vs PATCHED"
python3 "$HERE/join90.py" "$W/g.cen" "$W/pat.cen" | tail -1
echo "== $R : whole-dump PRISTINE vs PATCHED (ids stripped, paths normalised)"
for t in pris pat; do
  src=$B; [ $t = pat ] && src=$A
  "$DUMP" "$src/$R/slang.uhdm" 2>/dev/null | sed 1d |
    sed -E 's/, id:[0-9]+//g; s#/[^ ,]*/##g' > "$W/$t.dump"
done
diff "$W/pris.dump" "$W/pat.dump" > "$W/dump.diff"
echo "moved dump lines: $(grep -cE '^[<>]' "$W/dump.diff"; true)"
echo "-- ADDED (patched) line-kind histogram:"
grep -E '^>' "$W/dump.diff" | sed -E 's/^> *//; s/^\\_//; s/:.*//' | sort | uniq -c | sort -rn | head -12
echo "-- REMOVED (pristine) line-kind histogram:"
grep -E '^<' "$W/dump.diff" | sed -E 's/^< *//; s/^\\_//; s/:.*//' | sort | uniq -c | sort -rn | head -12
echo "-- every ADDED/REMOVED line's nearest enclosing OWNER (super.new sites only):"
grep -E '^[<>]' "$W/dump.diff" | grep -c 'super.new' || true
echo "WD=$W"

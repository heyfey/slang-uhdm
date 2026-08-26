#!/usr/bin/env bash
# r10uvm154 — PROOF that the boundary's TAILONLY moves are a pre-existing,
# BINARY-LAYOUT-DERIVED artifact and not this law.
#
#   PRI=<pristine> PAT=<patched> layoutproof154.sh
#
# `l154_noenum.sv` contains NO ENUM AT ALL, so § enumWrittenNegDecLit154's code
# cannot execute on it -- and the two binaries STILL disagree on the value of
# the tail constant our emitter mints for a class-scoped
# `typedef <T> name[string]`.  The number is layout-derived (the two readings
# differ by exactly 4096), lives BELOW `\_weaklyReferenced:` where RESUME.md §9
# says the judge cannot reach, and moves for ANY code motion in the emitter.
#
# It is also invisible to both corpora: byteverify.sh reports 0 unpredicted
# movers on 956 surelog and 1358 uhdm2rtlil databases.
set -u
PRI=${PRI:?set PRI}; PAT=${PAT:?set PAT}
HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
WD=${WD:-/tmp/r10uvm154_layout}
rm -rf "$WD"; mkdir -p "$WD"; cp "$HERE/l154_noenum.sv" "$WD/" || exit 9
cd "$WD" || exit 9
echo "enum keywords in the source: $(grep -c '\<enum\>' l154_noenum.sv; true)  (must be 0)"
for w in pris pat; do
  [ "$w" = pris ] && B=$PRI || B=$PAT
  "$B" l154_noenum.sv --single-unit -o db.uhdm >/dev/null 2>&1
  [ -f db.uhdm ] || { echo "FATAL: $w produced no database"; exit 5; }
  "$DUMP" db.uhdm 2>/dev/null > $w.full
  awk 'BEGIN{d=1} /^\\_weaklyReferenced:/{d=0} d==1{print}' $w.full | sed 1d > $w.head
  awk 'BEGIN{d=0} /^\\_weaklyReferenced:/{d=1} d==1{print}' $w.full > $w.tail
  echo "$w: tail value(s) = $(grep -oE '(UINT|INT):[0-9]{7,}' $w.tail | sort -u | tr '\n' ' ')"
  rm -f db.uhdm
done
if diff -q pris.head pat.head >/dev/null; then
  echo "JUDGE-VISIBLE HEAD IDENTICAL (the two binaries agree on everything uhdm-cmp reads)"
else
  echo "JUDGE-VISIBLE HEAD DIFFERS -- the proof does NOT hold, investigate"; exit 6
fi
if diff -q pris.tail pat.tail >/dev/null; then
  echo "TAIL IDENTICAL TOO -- nothing to prove on this build pair"
else
  echo "TAIL DIFFERS with no enum in the source => LAYOUT-DERIVED, not this law"
fi
echo "LAYOUTPROOF OK"

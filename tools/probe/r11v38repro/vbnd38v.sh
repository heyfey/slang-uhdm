#!/usr/bin/env bash
# r11v38 — THE TRACE-FREE WIDE BOUNDARY.
#
# The implementer's `boundary38.sh` names an arm by the law's OWN debug trace:
# it can only see what the law says it claims.  This one compiles EVERY
# committed probe arm with BOTH binaries and BYTE-COMPARES the two databases,
# so an arm whose database changes is named whether or not any law traced a
# cell there.  That difference is load-bearing: it found THREE arms
# (`r10buvm22repro/g22.sv`, `r10uvm154repro/l154_noenum.sv`,
# `r10uvm185repro/grid185/g185_e_kinds.sv`) that the trace-based boundary did
# not name — and then the neutral binary (`R11U38_OFF=1`, which writes nothing)
# reproduced the same change on them, which is how they were attributed to a
# PRE-EXISTING build-dependent value and not to either law.
#
#   usage: PRIS=<pristine> LAW=<candidate> ROOT=<probe root> OUT=<dir> vbnd38v.sh
#
# GUARDS: subdirectory arms are included (a full `find`, not a top-level glob);
# PROCESSED is asserted against LISTED; each arm records BOTH rcs; a compile
# that produces no database is bucketed NODB and counted, never silently
# skipped.
set -u
PRIS=${PRIS:?pristine binary}
LAW=${LAW:?candidate binary}
ROOT=${ROOT:-$(cd "$(dirname "$0")/.." && pwd)}
OUT=${OUT:?outdir}
JOBS=${JOBS:-4}
[ -x "$PRIS" ] && [ -x "$LAW" ] || { echo "FATAL: binary not executable"; exit 3; }
mkdir -p "$OUT" || exit 3
find "$ROOT" \( -name '*.sv' -o -name '*.svh' -o -name '*.v' \) -type f | sort > "$OUT/list.txt"
one() {
  f=$1
  w=$(mktemp -d /tmp/r11v38bnd.XXXXXX)
  ( cd "$(dirname "$f")" && "$PRIS" "$(basename "$f")" --single-unit -o "$w/p.uhdm" ) \
      >/dev/null 2>&1 </dev/null
  prc=$?
  ( cd "$(dirname "$f")" && "$LAW" "$(basename "$f")" --single-unit -o "$w/l.uhdm" ) \
      >/dev/null 2>&1 </dev/null
  lrc=$?
  st=SAME
  if [ -f "$w/p.uhdm" ] && [ -f "$w/l.uhdm" ]; then
    cmp -s "$w/p.uhdm" "$w/l.uhdm" || st=DIFF
  else
    st=NODB
  fi
  printf '%s %s prc=%s lrc=%s\n' "$st" "$f" "$prc" "$lrc"
  rm -rf "$w"
}
export -f one; export PRIS LAW
xargs -a "$OUT/list.txt" -d '\n' -P "$JOBS" -I{} bash -c 'one "$@"' _ {} > "$OUT/res.txt"
listed=$(wc -l < "$OUT/list.txt"); processed=$(wc -l < "$OUT/res.txt")
echo "-- LISTED=$listed PROCESSED=$processed"
echo "-- DIFF=$(grep -c '^DIFF ' "$OUT/res.txt"; true) NODB=$(grep -c '^NODB ' "$OUT/res.txt"; true) SAME=$(grep -c '^SAME ' "$OUT/res.txt"; true)"
grep '^DIFF ' "$OUT/res.txt" | sort
[ "$listed" -eq "$processed" ] || { echo "GATE: PROCESSED != LISTED"; exit 5; }
echo "BOUNDARY DRIVER: OK"

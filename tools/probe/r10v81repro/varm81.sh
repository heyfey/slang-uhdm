#!/usr/bin/env bash
# r10v81 — ONE ARM: Surelog golden + both frozen binaries + the R10E81_OFF=1
# neutral, in BOTH views, censused with selcen81 and vall81.  rc RECORDED for
# every cell (verify_golden.py records rc=139 as SLANG_REJECT — RESUME §9).
# MEASUREMENT ONLY.  Dispatches nothing but the file named on the command line.
set -u
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
CEN=/tmp/v81_work/selcen81
ALL=/tmp/v81_work/vall81
PRIS=/tmp/v81_bin/pris
PATCHED=/tmp/v81_bin/patched
F=$(readlink -f "$1"); mkdir -p "$2"; D=$(readlink -f "$2"); B=$(basename "$F")
cp "$F" "$D/"
( cd "$D" && "$SL" -parse -nobuiltin -nocache -sv "$B" >sl.log 2>&1 </dev/null ); echo "SL rc=$?"
for c in slpp_all slpp_unit; do [ -f "$D/$c/surelog.uhdm" ] && cp "$D/$c/surelog.uhdm" "$D/g.uhdm"; done
( cd "$D" && "$PRIS" "$B"            -o o.uhdm  >o.log  2>&1 </dev/null ); echo "pris  rc=$?"
( cd "$D" && "$PRIS" "$B" --elabuhdm -o oe.uhdm >oe.log 2>&1 </dev/null ); echo "prisE rc=$?"
( cd "$D" && "$PATCHED" "$B"            -o q.uhdm  >q.log  2>&1 </dev/null ); echo "patc  rc=$?"
( cd "$D" && "$PATCHED" "$B" --elabuhdm -o qe.uhdm >qe.log 2>&1 </dev/null ); echo "patcE rc=$?"
( cd "$D" && R10E81_OFF=1 "$PATCHED" "$B"            -o n.uhdm  >n.log  2>&1 </dev/null ); echo "neutr rc=$?"
( cd "$D" && R10E81_OFF=1 "$PATCHED" "$B" --elabuhdm -o ne.uhdm >ne.log 2>&1 </dev/null ); echo "neutrE rc=$?"
for t in g o oe q qe n ne; do
  [ -f "$D/$t.uhdm" ] || continue
  "$CEN" "$D/$t.uhdm" 2>/dev/null > "$D/$t.cen"
  "$ALL" "$D/$t.uhdm" 2>/dev/null > "$D/$t.all"
  echo "$t sel=$(wc -l < "$D/$t.cen") all=$(wc -l < "$D/$t.all")"
done
echo "WD=$D"

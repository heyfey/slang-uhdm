#!/bin/bash
# r10uvm149 — run pred149 over EVERY golden database a verify_golden workdir
# reached, and name the rows that CAN move.  MEASUREMENT ONLY.
#
#   usage: pred149.sh <workdir> <pred149> <out.txt>
#
# GUARDS: the golden path is read out of each row's OWN cmds.txt (never
# guessed), the cache DIRECTORY is turned into .../golden.uhdm, rows with no
# golden are COUNTED as SKIP-NOFILE (a scan that reached nothing must not read
# as "no movers"), scratch is keyed on the RELATIVE row path, and every rc is
# recorded.
set -u
WD=${1:?workdir}; P=${2:?pred149}; OUT=${3:?out}
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
[ -x "$P" ] || { echo "FATAL: no pred149 $P"; exit 3; }
: > "$OUT"
seen=0; miss=0; hit=0
for mode in default testflags; do
  [ -d "$WD/$mode" ] || continue
  for d in "$WD/$mode"/*/; do
    [ -d "$d" ] || continue
    rel=${d#"$WD"/}; rel=${rel%/}
    C=$d/cmds.txt; G=""
    [ -f "$C" ] && G=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$C" | head -1)
    [ -n "$G" ] && [ -d "$G" ] && G=$G/golden.uhdm
    seen=$((seen+1))
    if [ -z "$G" ] || [ ! -f "$G" ]; then
      echo "SKIP-NOFILE	$rel" >> "$OUT"; miss=$((miss+1)); continue
    fi
    o=$("$P" "$G" "$rel" 2>&1); rc=$?
    echo "$o" | sed "s/\$/	rc=$rc/" >> "$OUT"
    n=$(echo "$o" | sed -n 's/^TOTAL\t.*\tcands=\([0-9]*\)$/\1/p')
    [ -n "$n" ] && [ "$n" -gt 0 ] && hit=$((hit+1))
  done
done
echo "-- rows=$seen SKIP-NOFILE=$miss WITH-CANDIDATES=$hit"

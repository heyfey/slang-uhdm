#!/usr/bin/env bash
# r10uvm203 — run ct203pred over EVERY database in a sweep workdir.
# MEASUREMENT ONLY.  Run on the PRISTINE sweep it names the byte movers before
# the patched binary exists.  Every database is visited and counted, so a
# driver that reaches nothing cannot read as "no movers".
#
# usage: pred203.sh <sweep workdir> <ct203pred> <out>
set -u
WD=${1:?workdir}; P=${2:?predbin}; OUT=${3:?out}
[ -d "$WD" ] || { echo "FATAL: no workdir $WD"; exit 3; }
: > "$OUT"
seen=0; nodb=0
while IFS= read -r d; do
  seen=$((seen+1))
  mode=$(basename "$(dirname "$d")")
  name=$(basename "$d"); name=${name%-*}
  if [ -f "$d/slang.uhdm" ]; then
    "$P" "$d/slang.uhdm" "$name/$mode" >> "$OUT" 2>&1
  else
    echo "PRED $name/$mode NOFILE FIRES=0" >> "$OUT"; nodb=$((nodb+1))
  fi
done < <(find "$WD" -mindepth 2 -maxdepth 2 -type d | sort)
echo "-- VISITED=$seen NODB=$nodb FIRING=$(grep -c ' FIRES=[1-9]' "$OUT"; true)" >> "$OUT"
tail -1 "$OUT"

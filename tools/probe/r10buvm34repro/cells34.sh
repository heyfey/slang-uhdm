#!/usr/bin/env bash
# r10buvm34repro/cells34.sh — build the 3-SIDE census tsv for ONE arm:
# golden (G), the frozen PRISTINE binary (P) and the frozen PATCHED one (O),
# both views.  Every command and its rc is echoed into each workdir's cmds.txt
# by arm34.sh, so the binary each database came from is auditable BY PATH.
#   cells34.sh <file.sv> <pris.bin> <pat.bin> <workdir-prefix> <cen> <out.tsv>
set -u
D=$(cd "$(dirname "$0")" && pwd)
SV=$1; PB=$2; QB=$3; W=$4; CEN=$5; OUT=$6
bash "$D/arm34.sh" "$SV" "$PB" "${W}_p" >/dev/null 2>&1
bash "$D/arm34.sh" "$SV" "$QB" "${W}_q" >/dev/null 2>&1
: > "$OUT"
for v in def elab; do
  "$CEN" "${W}_p/g_$v/slpp_all/surelog.uhdm" "G|$v" >> "$OUT" 2>/dev/null
  "$CEN" "${W}_p/o_$v.uhdm"                  "P|$v" >> "$OUT" 2>/dev/null
  "$CEN" "${W}_q/o_$v.uhdm"                  "O|$v" >> "$OUT" 2>/dev/null
done
echo "rows=$(wc -l < "$OUT")  -> $OUT"

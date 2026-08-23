#!/usr/bin/env bash
# r10uvm103repro/fence103.sh — ENUMERATE, from the PRISTINE databases alone and
# BEFORE the patched sweep exists, every database this law can reach.
#
# The law's fossil is exact and enumerable: golden NEVER puts a `hier_path` in a
# STATEMENT slot with a call as its last path element (0 such rows over every
# golden in the three grid arms), and that is precisely what the Invalid shell
# made our emitter build.  So the predicted mover set is
#     every database with at least one `HPCALL POS=STMT` census row.
#
#   fence103.sh <sweep workdir> <cen bin> <out.tsv>
# Keys every scratch on the RELATIVE path (r10uvm33repro keeps three dut.sv).
set -u
WD=${1:?workdir}; CEN=${2:?cen}; OUT=${3:?out}
: > "$OUT"
find "$WD" -name slang.uhdm -print0 |
  xargs -0 -P "${JOBS:-3}" -I{} bash -c '
    f="$1"; rel=${f#'"$WD"'/}; rel=${rel%/slang.uhdm}
    "'"$CEN"'" "$f" "$rel" 2>/dev/null | grep -P "\tHPCALL\t.*POS=STMT" || true
  ' _ {} >> "$OUT"
echo "rows=$(wc -l < "$OUT")  dbs=$(cut -f1 "$OUT" | sort -u | wc -l)"

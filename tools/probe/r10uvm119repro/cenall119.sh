#!/usr/bin/env bash
# r10uvm119repro/cenall119.sh — run cen119.py over BOTH SIDES of every named
# cell of a verify_golden workdir.  MEASUREMENT ONLY.
#
#   cenall119.sh <workdir> <outdir> <cell> [cell...]
#
# The golden database is found by reading the cell's OWN cmds.txt (the golden
# cache hit line), so no path is ever guessed; every command records its rc.
set -u
W=$1; OUT=$2; shift 2
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
HERE=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$OUT"; : > "$OUT/cenall.cmds.txt"
for cell in "$@"; do
  for mode in default testflags; do
    d=$(ls -d "$W/$mode/$cell"-* 2>/dev/null | head -1)
    [ -z "$d" ] && { echo "SKIP-NOCELL $cell/$mode" >> "$OUT/cenall.cmds.txt"; continue; }
    [ -f "$d/slang.uhdm" ] || { echo "SKIP-NOOURS $cell/$mode" >> "$OUT/cenall.cmds.txt"; continue; }
    G=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$d/cmds.txt" | head -1)
    [ -z "$G" ] || [ ! -f "$G/golden.uhdm" ] && { echo "SKIP-NOGOLD $cell/$mode" >> "$OUT/cenall.cmds.txt"; continue; }
    echo "cell $cell/$mode ours=$d/slang.uhdm gold=$G/golden.uhdm" >> "$OUT/cenall.cmds.txt"
    "$DUMP" "$G/golden.uhdm" 2>/dev/null > "$OUT/.g.txt"; echo "rc=$? dump gold $cell/$mode" >> "$OUT/cenall.cmds.txt"
    "$DUMP" "$d/slang.uhdm"   2>/dev/null > "$OUT/.o.txt"; echo "rc=$? dump ours $cell/$mode" >> "$OUT/cenall.cmds.txt"
    python3 "$HERE/cen119.py" "$OUT/.g.txt" "$cell.$mode" > "$OUT/cen.g.$cell.$mode.txt"
    echo "rc=$? cen gold $cell/$mode" >> "$OUT/cenall.cmds.txt"
    python3 "$HERE/cen119.py" "$OUT/.o.txt" "$cell.$mode" > "$OUT/cen.o.$cell.$mode.txt"
    echo "rc=$? cen ours $cell/$mode" >> "$OUT/cenall.cmds.txt"
    rm -f "$OUT/.g.txt" "$OUT/.o.txt"
  done
done

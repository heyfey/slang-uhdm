#!/usr/bin/env bash
# r10uvm126 — the WIDE census: cen126 over every UVM row-mode's GOLDEN database
# and over the same row's OURS database, scored with score126.py.
# LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY — the official uhdm-cmp is the judge.
#   usage: WD=<sweep workdir> CEN126=.. wide125.sh <outdir> [rows...]
set -u
WD=${WD:?set WD to a verify_golden workdir}
CEN=${CEN126:?set CEN126}
OUT=$(readlink -f "$1"); shift
mkdir -p "$OUT"
ROWS=${*:-"SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg"}
HERE=$(cd "$(dirname "$0")" && pwd)
for m in default testflags; do
  for t in $ROWS; do
    d=$(ls -d "$WD/$m/$t"-* 2>/dev/null | head -1); [ -n "$d" ] || { echo "$m/$t NODIR"; continue; }
    # the golden path is read out of the row's OWN cmds.txt (never guessed), and
    # the cache DIRECTORY is turned into .../golden.uhdm — handing uhdm-cmp or a
    # Serializer a directory compares/restores nothing.
    g=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
    [ -n "$g" ] && [ -e "$g/golden.uhdm" ] || { echo "$m/$t NOGOLD"; continue; }
    [ -e "$d/slang.uhdm" ] || { echo "$m/$t NOOURS"; continue; }
    "$CEN" "$g/golden.uhdm" > "$OUT/$t.$m.g.cen"  2>/dev/null
    "$CEN" "$d/slang.uhdm" > "$OUT/$t.$m.o.cen"  2>/dev/null
    PAT=""
    if [ -n "${WDPAT:-}" ]; then
      dp=$(ls -d "$WDPAT/$m/$t"-* 2>/dev/null | head -1)
      if [ -n "$dp" ] && [ -e "$dp/slang.uhdm" ]; then
        "$CEN" "$dp/slang.uhdm" > "$OUT/$t.$m.q.cen" 2>/dev/null
        PAT="$OUT/$t.$m.q.cen"
      fi
    fi
    python3 "$HERE/score126.py" "$OUT/$t.$m.g.cen" "$OUT/$t.$m.o.cen" $PAT --cells \
      > "$OUT/$t.$m.score" 2>&1
    echo "== $t/$m"; grep -E '^(AGREE|LAW|RESIDUE|ONLY|BROKE|PATCH-ONLY|KINDPAIR LAW)' "$OUT/$t.$m.score" | sed 's/^/   /' 
  done
done

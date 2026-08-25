#!/usr/bin/env bash
# r10uvm133 — the WIDE query-call census / A-PRIORI PREDICTOR.
# For every sweep-workdir row listed on stdin ("<mode>/<dir>") it dumps the
# row's OWN golden (path read out of that row's cmds.txt, never guessed) and
# our database, censuses both with qcen133.py and joins them with qjoin133.py.
# When WDPAT is set the patched row is dumped and joined too.
# LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY — the official uhdm-cmp is the judge.
#   usage: WD=<pristine workdir> [WDPAT=<patched workdir>] wide133.sh <outdir> < rows.txt
set -u
WD=${WD:?set WD}
OUT=$(readlink -f "${1:?outdir}"); mkdir -p "$OUT"
HERE=$(cd "$(dirname "$0")" && pwd)
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
while read -r row rest; do
  row=${row%/}
  [ -n "$row" ] || continue
  d="$WD/$row"
  [ -f "$d/slang.uhdm" ] || { echo "$row NOOURS"; continue; }
  g=$(sed -n 's#.*golden cache hit \(/[^)]*\).*#\1#p' "$d/cmds.txt" | head -1)
  [ -n "$g" ] && [ -e "$g/golden.uhdm" ] || { echo "$row NOGOLD"; continue; }
  key=$(echo "$row" | tr '/' '.')
  "$DUMP" "$g/golden.uhdm"  2>/dev/null | sed 1d > "$OUT/$key.g.dump"
  "$DUMP" "$d/slang.uhdm"   2>/dev/null | sed 1d > "$OUT/$key.o.dump"
  args=("$OUT/$key.g.dump" "$OUT/$key.o.dump")
  if [ -n "${WDPAT:-}" ] && [ -f "$WDPAT/$row/slang.uhdm" ]; then
    "$DUMP" "$WDPAT/$row/slang.uhdm" 2>/dev/null | sed 1d > "$OUT/$key.q.dump"
    args+=("$OUT/$key.q.dump")
  fi
  python3 "$HERE/qjoin133.py" "${args[@]}" --rows | sed "s#^#$row\t#" | tee "$OUT/$key.join"
done

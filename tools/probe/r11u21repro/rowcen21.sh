#!/usr/bin/env bash
# r11u21 — the KEYED DIRECTIONAL census (dircen21.py) on named SWEEP rows,
# each against ITS OWN golden.  Reads the golden out of the row's cmds.txt so
# the cache entry is never guessed.
#   usage: GOLD_PRIS=<pristine workdir> GOLD_PAT=<patched workdir> \
#          rowcen21.sh <mode> <row> [<row> ...]
set -u
D=$(cd "$(dirname "$0")" && pwd)
UD=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
WP=${GOLD_PRIS:?set GOLD_PRIS}
WQ=${GOLD_PAT:?set GOLD_PAT}
MODE=$1; shift
T=${TMPDIR:-/tmp}/r11u21_rowcen.$$
mkdir -p "$T"
for row in "$@"; do
  pd=$(ls -d "$WP/$MODE/$row"-* 2>/dev/null | head -1)
  qd=$(ls -d "$WQ/$MODE/$row"-* 2>/dev/null | head -1)
  if [ -z "$pd" ] || [ -z "$qd" ]; then echo "$row $MODE NODIR"; continue; fi
  g=$(grep -o '/home/heyfey/.cache/slang-uhdm-goldens/[0-9a-f]*' "$pd/cmds.txt" | head -1)
  if [ -z "$g" ] || [ ! -f "$g/golden.uhdm" ]; then echo "$row $MODE NOGOLD"; continue; fi
  "$UD" "$g/golden.uhdm" > "$T/g.dump" 2>/dev/null
  "$UD" "$pd/slang.uhdm" > "$T/p.dump" 2>/dev/null
  "$UD" "$qd/slang.uhdm" > "$T/q.dump" 2>/dev/null
  printf '%-40s %-9s ' "$row" "$MODE"
  python3 "$D/dircen21.py" "$T/g.dump" "$T/p.dump" "$T/q.dump" | tail -1
done
rm -rf "$T"

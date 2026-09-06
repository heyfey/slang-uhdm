#!/usr/bin/env bash
# r10v177repro/vpredict177.sh — PREDICT the byte movers BY NAME, from the
# PRISTINE databases and the GOLDEN ones, before looking at any patched sweep.
#
#   vpredict177.sh <pristine sweep workdir root> <out prefix>
#
# The prediction rule, stated in advance and independent of the emitter:
#   § ownNamedAliasRetIsRefVar177 can ONLY change a function's return-variable
#   KIND, and it only ever produces a bare `ref_var`.  So a database can move
#   at all only if it holds a `function` whose GOLDEN return variable is a
#   `ref_var` while OURS is something else.  Every such database is listed as a
#   CANDIDATE, with the function named.  A mover outside this set would be a
#   move AWAY from golden and must be convicted.
#
# The golden database for each row is read out of that row's own `cmds.txt`
# (`golden cache hit <path>`), so no path is guessed.
set -u
ROOT=${1:?pristine workdir root}
OUT=${2:?output prefix}
SCAN=${VRETSCAN:-/tmp/v177_vretscan}
[ -x "$SCAN" ] || { echo "FATAL: no vretscan177 at $SCAN"; exit 3; }
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
: > "$OUT.cand"; : > "$OUT.log"
n=0; cand=0
while read -r db; do
  n=$((n + 1))
  d=$(dirname "$db")
  g=$(grep -oE '/home/heyfey/\.cache/slang-uhdm-goldens/[0-9a-f]+' "$d/cmds.txt" 2>/dev/null | head -1)
  rel=${db#"$ROOT"/}
  [ -n "$g" ] && [ -d "$g" ] && g="$g/golden.uhdm"
  if [ -z "$g" ] || [ ! -f "$g" ]; then
    echo "NOGOLDEN $rel" >> "$OUT.log"; continue
  fi
  "$SCAN" "$g"  > "$OUT.tmp.g" 2>/dev/null || { echo "SCANFAIL-G $rel" >> "$OUT.log"; continue; }
  "$SCAN" "$db" > "$OUT.tmp.o" 2>/dev/null || { echo "SCANFAIL-O $rel" >> "$OUT.log"; continue; }
  # keys: function fullname + span; value: return kind
  hits=$(join -t $'\t' -1 1 -2 1 \
           <(awk -F'\t' '{print $2"@"$3"\t"$1}' "$OUT.tmp.g" | sort -u) \
           <(awk -F'\t' '{print $2"@"$3"\t"$1}' "$OUT.tmp.o" | sort -u) \
         | awk -F'\t' '$2=="ref_var" && $3!="ref_var" {print}')
  if [ -n "$hits" ]; then
    cand=$((cand + 1))
    echo "CANDIDATE $rel" >> "$OUT.cand"
    echo "$hits" | sed 's/^/    /' >> "$OUT.cand"
  fi
done < <(find "$ROOT" -name slang.uhdm | sort)
rm -f "$OUT.tmp.g" "$OUT.tmp.o"
# A gate that could not READ its goldens reports "no candidates" exactly like a
# clean run, so the two blindness counters are part of the verdict.
echo "SCANNED=$n CANDIDATE_DBS=$cand NOGOLDEN=$(grep -c '^NOGOLDEN ' "$OUT.log"; true) SCANFAIL=$(grep -c '^SCANFAIL' "$OUT.log"; true)"

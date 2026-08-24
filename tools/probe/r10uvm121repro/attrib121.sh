#!/bin/bash
# r10uvm121 — ORDER-BLIND mover attribution (measurement only).
#
# Scoreboard/default is a ~50/50 COIN (RESUME §9), so the dumps are
# path-normalised AND SORTED before the diff: what survives is content, not
# order.  Prints, per mover, the count of lines removed / added and the
# distinct removed/added line texts.
#   usage: attrib121.sh <patched-workdir> <pristine-workdir> <outdir>
set -u
X=${1:?patched wd}; P=${2:?pristine wd}; O=${3:?outdir}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
mkdir -p "$O"
( cd "$X" && find . -name slang.uhdm | LC_ALL=C sort ) > "$O/paths.txt"
n=0
while IFS= read -r rel <&3; do
  [ -f "$P/$rel" ] || continue
  a=$(md5sum "$X/$rel" | cut -d' ' -f1); b=$(md5sum "$P/$rel" | cut -d' ' -f1)
  [ "$a" = "$b" ] && continue
  n=$((n+1))
  key=$(printf '%s' "$rel" | sed 's#^\./##; s#/#__#g')
  "$DUMP" "$P/$rel" 2>&1 </dev/null | sed "s#$P##g; s#$X##g" | LC_ALL=C sort > "$O/$key.p.txt"
  "$DUMP" "$X/$rel" 2>&1 </dev/null | sed "s#$P##g; s#$X##g" | LC_ALL=C sort > "$O/$key.x.txt"
  diff "$O/$key.p.txt" "$O/$key.x.txt" > "$O/$key.diff" 2>&1
  rem=$(grep -c '^<' "$O/$key.diff"; true); add=$(grep -c '^>' "$O/$key.diff"; true)
  echo "== $rel  removed=$rem added=$add"
  grep '^<' "$O/$key.diff" | sed 's/^< *//' | LC_ALL=C sort | uniq -c | sed 's/^/   REMOVED /'
  grep '^>' "$O/$key.diff" | sed 's/^> *//' | LC_ALL=C sort | uniq -c | sed 's/^/   ADDED   /'
done 3< "$O/paths.txt"
echo "-- movers attributed: $n"

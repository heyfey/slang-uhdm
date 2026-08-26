#!/usr/bin/env bash
# v158 VERIFIER a-priori prediction, from PRISTINE databases only.
# For every row of a verify_golden workdir: census golden and OUR PRISTINE db,
# and report every statement block where GOLDEN lists variables and OUR
# vpiVariables vector is NULL (-1) -- and the reverse bucket, which must be
# empty.  MEASUREMENT ONLY.
set -u
WD=${1:?workdir}; CEN=${2:?cenbin}; OUT=${3:?out.tsv}
: > "$OUT"
rows=0; skip=0
find "$WD" -mindepth 2 -maxdepth 2 -type d | LC_ALL=C sort > /tmp/v158_scr/.predrows
exec 3< /tmp/v158_scr/.predrows
while IFS= read -r d <&3; do
  rows=$((rows+1))
  ours="$d/slang.uhdm"
  gc=$(sed -n 's/^surelog: (golden cache hit \(.*\))$/\1/p' "$d/cmds.txt" 2>/dev/null | head -1)
  gold=""
  [ -n "$gc" ] && [ -f "$gc/golden.uhdm" ] && gold="$gc/golden.uhdm"
  if [ ! -f "$ours" ] || [ -z "$gold" ]; then skip=$((skip+1)); continue; fi
  mode=$(basename "$(dirname "$d")"); name=$(basename "$d")
  "$CEN" "$gold" G > /tmp/v158_scr/.pg.txt 2>/dev/null </dev/null
  "$CEN" "$ours" O > /tmp/v158_scr/.po.txt 2>/dev/null </dev/null
  python3 /tmp/v158_scr/v158pred2.py /tmp/v158_scr/.pg.txt /tmp/v158_scr/.po.txt "$mode/$name" >> "$OUT"
done
exec 3<&-
echo "PRED rows=$rows SKIP-NOFILE=$skip toward=$(grep -c '^TOWARD' "$OUT" || true) away=$(grep -c '^AWAY' "$OUT" || true)"

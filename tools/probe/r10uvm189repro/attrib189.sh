#!/usr/bin/env bash
# r10uvm189repro/attrib189.sh — ORDER-BLIND attribution of every byte mover.
# MEASUREMENT ONLY.  For each row whose database moved, dumps BOTH sides,
# normalises the workdir path out (dump paths embed the workdir — RESUME §9),
# sorts (order-blind, so a pure ORDER flip such as the Scoreboard/default coin
# reports 0 content lines) and prints the per-kind histogram of the diff.
#   attrib189.sh <pristine wd> <patched wd> <outdir> <row-name regex>
set -u
PW=$1; AW=$2; OUT=$3; RE=$4
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
mkdir -p "$OUT"
find "$PW" -name slang.uhdm | sort | while IFS= read -r p; do
  rel=${p#$PW/}
  a=$AW/$rel
  [ -f "$a" ] || continue
  cmp -s "$p" "$a" && continue
  echo "$rel" | grep -qE "$RE" || { echo "UNEXPECTED-MOVER $rel"; }
  tag=$(echo "$rel" | sed 's#[^A-Za-z0-9._-]#_#g')
  "$DUMP" "$p" 2>/dev/null </dev/null | sed "s#$PW##g" | sed 1d | sort > "$OUT/$tag.pris.txt"
  "$DUMP" "$a" 2>/dev/null </dev/null | sed "s#$AW##g" | sed 1d | sort > "$OUT/$tag.pat.txt"
  n=$(diff "$OUT/$tag.pris.txt" "$OUT/$tag.pat.txt" | grep -cE '^[<>]'; true)
  echo "== $rel  order-blind diff lines=$n"
  diff "$OUT/$tag.pris.txt" "$OUT/$tag.pat.txt" | grep -E '^[<>]' \
    | sed -E 's/^([<>]) *//; s/[0-9]+/N/g' | sort | uniq -c | sort -rn | head -20
done

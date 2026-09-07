#!/usr/bin/env bash
# r10v195 — the WIDE BOUNDARY.  Every .sv/.v under a COPY of tools/probe, both
# views, PRISTINE vs FIXED, byte-compared.  MEASUREMENT ONLY.
# The file list is read on fd 3 with children </dev/null (RESUME §9); scratch is
# keyed on the RELATIVE path (several arms share a basename); every rc recorded.
set -u
ROOT=${1:?arm root}
A=${2:?pristine}
B=${3:?fixed}
OUT=${4:?outdir}
mkdir -p "$OUT"
: > "$OUT/moved.txt"; : > "$OUT/rc.txt"
listed=0; processed=0; dbs=0; moved=0; rcdiff=0
find "$ROOT" -name '*.sv' -o -name '*.v' | sort > "$OUT/list.txt"
listed=$(wc -l < "$OUT/list.txt")
while IFS= read -r f <&3; do
  processed=$((processed+1))
  rel=${f#"$ROOT"/}
  key=$(printf '%s' "$rel" | tr '/' '_')
  for v in def elab; do
    EF=""; [ "$v" = elab ] && EF="--elabuhdm"
    "$A" "$f" $EF -o "$OUT/a_${key}_$v.uhdm" >/dev/null 2>&1 </dev/null; ra=$?
    "$B" "$f" $EF -o "$OUT/b_${key}_$v.uhdm" >/dev/null 2>&1 </dev/null; rb=$?
    [ "$ra" != "$rb" ] && { echo "RCDIFF $rel $v a=$ra b=$rb" >> "$OUT/rc.txt"; rcdiff=$((rcdiff+1)); }
    if [ -f "$OUT/a_${key}_$v.uhdm" ] && [ -f "$OUT/b_${key}_$v.uhdm" ]; then
      dbs=$((dbs+1))
      ma=$(md5sum "$OUT/a_${key}_$v.uhdm" | cut -d' ' -f1)
      mb=$(md5sum "$OUT/b_${key}_$v.uhdm" | cut -d' ' -f1)
      [ "$ma" != "$mb" ] && { echo "MOVED $rel $v" >> "$OUT/moved.txt"; moved=$((moved+1)); }
    fi
    rm -f "$OUT/a_${key}_$v.uhdm" "$OUT/b_${key}_$v.uhdm"
  done
done 3< "$OUT/list.txt"
echo "LISTED=$listed PROCESSED=$processed PRODUCED_DBS=$dbs MOVED_CELLS=$moved RC_DIFFS=$rcdiff"
echo "MOVED_ARMS=$(cut -d' ' -f2 "$OUT/moved.txt" | sort -u | wc -l)"
cut -d' ' -f2 "$OUT/moved.txt" | sort -u

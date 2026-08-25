#!/usr/bin/env bash
# r10v129 verifier WIDE boundary, 2 workers. Same rules as vbound.sh:
# both frozen binaries, both views, children </dev/null, scratch keyed on the
# RELATIVE path, PROCESSED asserted, dump header line dropped before diffing.
set -u
PRIS=/tmp/v129_pris.bin; PAT=/tmp/v129_pat.bin
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
ROOT=$1; OUT=$2; W=${3:-0}; N=${4:-1}
mkdir -p "$OUT"
i=0
: > "$OUT/moved.$W.txt"; : > "$OUT/lines.$W.txt"; : > "$OUT/proc.$W.txt"
while IFS= read -r f <&3; do
  i=$((i+1)); [ $((i % N)) -eq "$W" ] || continue
  rel=${f#$ROOT/}; key=$(printf '%s' "$rel" | tr '/' '_')
  d="$OUT/w$W/$key"; mkdir -p "$d"; cp "$f" "$d/src.sv"
  for v in def elab; do
    fl=""; [ $v = elab ] && fl=--elabuhdm
    ( cd "$d" && "$PRIS" src.sv $fl -o p_$v.uhdm >/dev/null 2>&1 </dev/null )
    ( cd "$d" && "$PAT"  src.sv $fl -o q_$v.uhdm >/dev/null 2>&1 </dev/null )
    if [ -f "$d/p_$v.uhdm" ] && [ -f "$d/q_$v.uhdm" ]; then
      "$DUMP" "$d/p_$v.uhdm" 2>/dev/null | tail -n +2 > "$d/p.txt"
      "$DUMP" "$d/q_$v.uhdm" 2>/dev/null | tail -n +2 > "$d/q.txt"
      n=$(diff "$d/p.txt" "$d/q.txt" | grep -c '^[<>]'; true)
      if [ "$n" -gt 0 ]; then echo "MOVED $rel/$v $n" >> "$OUT/moved.$W.txt"
        diff "$d/p.txt" "$d/q.txt" | grep '^[<>]' >> "$OUT/lines.$W.txt"; fi
    else
      echo "NOPAIR $rel/$v" >> "$OUT/moved.$W.txt"
    fi
  done
  rm -f "$d"/*.uhdm "$d/p.txt" "$d/q.txt"
  echo "$rel" >> "$OUT/proc.$W.txt"
done 3< <(find "$ROOT" \( -name '*.sv' -o -name '*.v' \) | sort)
echo "WORKER $W DONE processed=$(wc -l < "$OUT/proc.$W.txt")"

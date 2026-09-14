#!/usr/bin/env bash
# r11v23 wide boundary gate: compile EVERY probe source (top-level and
# subdirectory alike) with BOTH frozen binaries and compare bytes.
# PROCESSED must equal LISTED; the file list is read on fd 3 and every child
# gets </dev/null so a child cannot eat the list.
set -u
ROOT=${ROOT:?}; A=${A:?}; B=${B:?}; OUT=${OUT:?}
SCRATCH=${SCRATCH:?}
rm -rf "$SCRATCH"; mkdir -p "$SCRATCH"
: > "$OUT"
n=0; moved=0; rcdiff=0
find "$ROOT" -name '*.sv' -o -name '*.v' | sort > "$SCRATCH/list.txt"
LISTED=$(wc -l < "$SCRATCH/list.txt")
while IFS= read -r f <&3; do
  n=$((n+1))
  rel=${f#$ROOT/}
  key=$(echo "$rel" | tr '/' '_')
  d="$SCRATCH/$key"; mkdir -p "$d"
  ( cd "$(dirname "$f")" && "$A" "$(basename "$f")" --single-unit --nobuiltin -o "$d/a.uhdm" > "$d/a.log" 2>&1 </dev/null ); ra=$?
  ( cd "$(dirname "$f")" && "$B" "$(basename "$f")" --single-unit --nobuiltin -o "$d/b.uhdm" > "$d/b.log" 2>&1 </dev/null ); rb=$?
  if [ "$ra" != "$rb" ]; then rcdiff=$((rcdiff+1)); echo "RCDIFF $rel a=$ra b=$rb" >> "$OUT"; fi
  if [ -f "$d/a.uhdm" ] && [ -f "$d/b.uhdm" ]; then
    ma=$(md5sum "$d/a.uhdm" | cut -c1-12); mb=$(md5sum "$d/b.uhdm" | cut -c1-12)
    if [ "$ma" != "$mb" ]; then moved=$((moved+1)); echo "MOVED $rel a=$ma b=$mb" >> "$OUT"; fi
  elif [ -f "$d/a.uhdm" ] || [ -f "$d/b.uhdm" ]; then
    moved=$((moved+1)); echo "MOVED-ONESIDED $rel" >> "$OUT"
  fi
  rm -f "$d/a.uhdm" "$d/b.uhdm"
done 3< "$SCRATCH/list.txt"
echo "PROCESSED=$n LISTED=$LISTED MOVED=$moved RCDIFF=$rcdiff" >> "$OUT"
tail -1 "$OUT"

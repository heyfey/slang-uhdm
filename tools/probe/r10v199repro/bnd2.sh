#!/bin/bash
ROOT=${ROOT:?}; A=${A:?}; B=${B:?}; OUT=${OUT:?}
rel="$1"; key=$(echo "$rel" | tr '/' '_'); d="$OUT/arms/$key"; mkdir -p "$d"
( cd "$d" && timeout 120 "$A" "$ROOT/$rel" -o a.uhdm > a.log 2>&1 </dev/null ); arc=$?
( cd "$d" && timeout 120 "$B" "$ROOT/$rel" -o b.uhdm > b.log 2>&1 </dev/null ); brc=$?
r="?"
if [ "$arc" != "$brc" ]; then r="RCDIFF($arc/$brc)"
elif [ -f "$d/a.uhdm" ] && [ -f "$d/b.uhdm" ]; then
  if [ "$(md5sum < "$d/a.uhdm")" = "$(md5sum < "$d/b.uhdm")" ]; then r=SAME; else r=MOVED; fi
elif [ ! -f "$d/a.uhdm" ] && [ ! -f "$d/b.uhdm" ]; then r=NODB
else r=ONESIDED; fi
printf '%s %s\n' "$r" "$rel" > "$OUT/res/$key.txt"
rm -f "$d/a.uhdm" "$d/b.uhdm"

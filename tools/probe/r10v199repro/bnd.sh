#!/bin/bash
# r10v199 verifier WIDE BOUNDARY. Measurement only.
ROOT=${ROOT:?root}; PRIS=${PRIS:?}; PAT=${PAT:?}; OUT=${OUT:?}
rel="$1"
key=$(echo "$rel" | tr '/' '_')
d="$OUT/arms/$key"; mkdir -p "$d"
( cd "$d" && timeout 120 "$PRIS" "$ROOT/$rel" -o pris.uhdm > pris.log 2>&1 </dev/null ); prc=$?
( cd "$d" && timeout 120 "$PAT"  "$ROOT/$rel" -o pat.uhdm  > pat.log  2>&1 </dev/null ); qrc=$?
r="?"
if [ "$prc" != "$qrc" ]; then r="RCDIFF($prc/$qrc)"
elif [ -f "$d/pris.uhdm" ] && [ -f "$d/pat.uhdm" ]; then
  a=$(md5sum < "$d/pris.uhdm"); b=$(md5sum < "$d/pat.uhdm")
  if [ "$a" = "$b" ]; then r=SAME; else r=MOVED; fi
elif [ ! -f "$d/pris.uhdm" ] && [ ! -f "$d/pat.uhdm" ]; then r=NODB
else r=ONESIDED; fi
printf '%s %s\n' "$r" "$rel" > "$OUT/res/$key.txt"
rm -f "$d/pris.uhdm" "$d/pat.uhdm"

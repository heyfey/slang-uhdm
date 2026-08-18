#!/usr/bin/env bash
# r10uvm93 MOVER ATTRIBUTION.  For each moved row, the PATH-NORMALISED,
# ORDER-BLIND whole-dump diff (Scoreboard/default is a ~50/50 coin, so an
# order-sensitive diff there is noise).  Every surviving line must belong to
# § streamSliceTypeBits93: a slice-size constant's vpiDecompile / value /
# location, or the object-id renumbering those minted constants cause.
set -u
PAT=${PAT:?patched workdir root}
PRI=${PRI:?pristine workdir root}
DUMP=${UHDM_DUMP:-$HOME/git-repos/UHDM/build/bin/uhdm-dump}
OUT=${OUT:?output dir}
mkdir -p "$OUT"
for r in "$@"; do
  a="$PAT/$r/slang.uhdm"; b="$PRI/$r/slang.uhdm"
  [ -f "$a" ] && [ -f "$b" ] || { echo "MISSING $r"; continue; }
  k=$(echo "$r" | tr '/' '_')
  # normalise: strip the workdir prefix and every object id (minting shifts ids)
  norm() { "$DUMP" "$1" 2>/dev/null | sed 1d \
      | sed -e "s#$PAT##g" -e "s#$PRI##g" -e 's/, id:[0-9]*//g'; }
  norm "$b" | sort > "$OUT/$k.pris.snorm"
  norm "$a" | sort > "$OUT/$k.pat.snorm"
  d=$(diff "$OUT/$k.pris.snorm" "$OUT/$k.pat.snorm" | grep -E '^[<>]' > "$OUT/$k.diff"; wc -l < "$OUT/$k.diff")
  echo "== $r : $d order-blind, id-blind dump lines differ"
  sort "$OUT/$k.diff" | uniq -c | sort -rn | head -20
done

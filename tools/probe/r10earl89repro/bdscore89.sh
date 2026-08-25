#!/usr/bin/env bash
# r10earl89 — re-measure every WIDE-BOUNDARY differing file AGAINST GOLDEN.
# A boundary walk that only says "these cells moved" has not said whether they
# moved TOWARD golden.  Each file is rebuilt by `arm89.sh` (Surelog golden +
# both frozen binaries + the NEUTRAL one, both views) and scored twice: the
# whole cell (`score89.py`) and the ONE field this law owns (`tsscore89.py`).
#   usage: DIMTS89=.. PRIS=.. PATCHED=.. bdscore89.sh <difflist> <probe-root> <outdir>
set -u
LIST=$1; ROOT=$(readlink -f "$2"); OUT=$(readlink -f "$3"); mkdir -p "$OUT"
here=$(cd "$(dirname "$0")" && pwd)
awk '{print $2}' "$LIST" | sort -u | while read -r rel; do
  key=$(echo "$rel" | tr '/' '_'); key=${key%.sv}; key=${key%.v}
  d="$OUT/$key"
  bash "$here/arm89.sh" "$ROOT/$rel" "$d" > "$d.armlog" 2>&1
  for v in "" e; do
    lbl=$([ -z "$v" ] && echo def || echo elab)
    { echo "== $rel  $lbl  WHOLE CELL"; python3 "$here/score89.py" "$d/g$v.rg" "$d/o$v.rg" "$d/q$v.rg" 2>&1 | head -7
      echo "== $rel  $lbl  THE TS FIELD"; python3 "$here/tsscore89.py" "$d/g$v.rg" "$d/o$v.rg" "$d/q$v.rg" 2>&1
    } >> "$OUT/SCORE.$key.txt"
  done
  echo "== $rel  A/B: neutral==pristine def=$(cmp -s "$d/o.uhdm" "$d/n.uhdm" && echo YES || echo NO) elab=$(cmp -s "$d/oe.uhdm" "$d/ne.uhdm" && echo YES || echo NO)" >> "$OUT/SCORE.$key.txt"
  echo "$rel scored"
done

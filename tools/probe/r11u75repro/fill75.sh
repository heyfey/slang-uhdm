#!/usr/bin/env bash
# r11u75 — fills the surelog-side gate readings into README.md once the
# patched sweep lands.  Kept in the directory so the numbers in the record can
# be REGENERATED rather than retyped.
set -u
PRIS=${1:?pristine surelog csv}
PATCH=${2:?patched surelog csv}
for f in "$PRIS" "$PATCH"; do
  echo "== $f"
  for m in default testflags; do
    printf '   %-10s CMP_EQUAL=%s CMP_NOTEQUAL=%s\n' "$m" \
      "$(awk -F, -v m=$m '$2==m && $3=="CMP_EQUAL"' "$f" | wc -l)" \
      "$(awk -F, -v m=$m '$2==m && $3=="CMP_NOTEQUAL"' "$f" | wc -l)"
  done
done

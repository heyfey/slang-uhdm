#!/usr/bin/env bash
# v93 — PREDICT the mover set from PRISTINE DATABASES ONLY.
# A database moves iff its dump contains a stream-op operand constant whose
# vpiDecompile is one of the simple_type keyword spellings (what the patch
# rewrites).  Prints one line per predicted mover, keyed by relative path.
set -u
ROOT=${1:?pristine sl workdir}
DUMP=$HOME/git-repos/UHDM/build/bin/uhdm-dump
cd "$ROOT" || exit 9
find . -name slang.uhdm | sort > /tmp/v93_predlist.txt
n=0
while IFS= read -r p <&3; do
  n=$((n+1))
  "$DUMP" "$p" 2>/dev/null </dev/null > /tmp/v93_pred.dump
  c=$(grep -cE '^\s*\|vpiDecompile:(byte|shortint|int|integer|longint|bit|logic|reg|time|realtime|real|shortreal)$' /tmp/v93_pred.dump; true)
  [ "$c" -gt 0 ] && echo "PREDICT_MOVER $p keyword_decompile_cells=$c"
done 3< /tmp/v93_predlist.txt
echo "SCANNED=$n"

#!/usr/bin/env bash
# r10v139 (VERIFIER) — WIDE BOUNDARY.  Compile every .sv/.svh under a root with
# the PRISTINE and the PATCHED binary in BOTH views, to the SAME -o path, and
# compare the databases md5-first.  A file whose database MOVED is reported by
# its RELATIVE path (two arms may share a basename).  MEASUREMENT ONLY.
#   PRI= PAT= [ROOT=] [WD=] [CTRL=1] boundv139.sh
set -u
PRI=${PRI:?}; PAT=${PAT:?}
ROOT=${ROOT:-/tmp/wt_v139/tools/probe}
WD=${WD:-/tmp/v139_bound}
rm -rf "$WD"; mkdir -p "$WD"
LIST=$WD/files.txt
find "$ROOT" -type f \( -name '*.sv' -o -name '*.svh' \) | LC_ALL=C sort > "$LIST"
listed=$(wc -l < "$LIST"); proc=0; moved=0; norun=0; rcmm=0
: > "$WD/MOVED.txt"; : > "$WD/RCMISMATCH.txt"
exec 3< "$LIST"
while IFS= read -r f <&3; do
  rel=${f#$ROOT/}
  key=$(printf '%s' "$rel" | tr '/' '_')
  d=$WD/$key; mkdir -p "$d"
  for view in def elab; do
    [ "$view" = elab ] && X=--elabuhdm || X=
    ( cd "$(dirname "$f")" && "$PRI" "$(basename "$f")" --single-unit $X -o "$d/a.$view.uhdm" >"$d/a.$view.log" 2>&1 </dev/null ); ra=$?
    ( cd "$(dirname "$f")" && "$PAT" "$(basename "$f")" --single-unit $X -o "$d/b.$view.uhdm" >"$d/b.$view.log" 2>&1 </dev/null ); rb=$?
    if [ "$ra" != "$rb" ]; then rcmm=$((rcmm+1)); echo "$rel $view ra=$ra rb=$rb" >> "$WD/RCMISMATCH.txt"; continue; fi
    if [ ! -f "$d/a.$view.uhdm" ] || [ ! -f "$d/b.$view.uhdm" ]; then norun=$((norun+1)); continue; fi
    ma=$(md5sum "$d/a.$view.uhdm" | cut -d' ' -f1); mb=$(md5sum "$d/b.$view.uhdm" | cut -d' ' -f1)
    if [ "$ma" != "$mb" ]; then moved=$((moved+1)); echo "$rel $view" >> "$WD/MOVED.txt"; else rm -f "$d/a.$view.uhdm" "$d/b.$view.uhdm"; fi
  done
  proc=$((proc+1))
done
exec 3<&-
echo "LISTED=$listed PROCESSED=$proc MOVED=$moved NORUN=$norun RC-MISMATCH=$rcmm"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; exit 6; }
echo PROCESSED-ASSERT-OK

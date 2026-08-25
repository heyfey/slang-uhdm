#!/usr/bin/env bash
# r10v145 -- WIDE BOUNDARY: every .sv/.svh under tools/probe/, BOTH views,
# compiled by binary A and binary B TO THE SAME OUTPUT PATH (a database embeds
# its -o path), compared by md5.  Reports every file-view whose database MOVED
# and every rc MISMATCH.  MEASUREMENT ONLY.
#   A=<binA> B=<binB> ROOT=<tools/probe> OUT=<dir> [JOBS=n] bound145v.sh
# Ops traps paid for: SUBDIRECTORY arms are included; the scratch key is the
# RELATIVE path (r10uvm33repro keeps three files all named dut.sv); every child
# gets </dev/null; PROCESSED is asserted against LISTED; every rc is recorded.
set -u
A=${A:?}; B=${B:?}; ROOT=${ROOT:?}; OUT=${OUT:?}; JOBS=${JOBS:-3}
rm -rf "$OUT"; mkdir -p "$OUT/w"
LIST=$OUT/files.txt
( cd "$ROOT" && find . \( -name '*.sv' -o -name '*.svh' \) -type f | sort ) > "$LIST"
listed=$(wc -l < "$LIST")
run_one() {
  rel="$1"
  key=$(printf '%s' "$rel" | sed 's|^\./||; s|/|__|g')
  for view in def elab; do
    d="$OUT/w/$key.$view"; mkdir -p "$d"
    cp "$ROOT/$rel" "$d/src.sv" 2>/dev/null || { echo "$rel.$view NOCOPY"; continue; }
    if [ "$view" = elab ]; then X=--elabuhdm; else X=; fi
    ( cd "$d" && "$A" src.sv --single-unit $X -o out.uhdm > a.log 2>&1 </dev/null ); ra=$?
    [ -f "$d/out.uhdm" ] && mv "$d/out.uhdm" "$d/a.uhdm"
    ( cd "$d" && "$B" src.sv --single-unit $X -o out.uhdm > b.log 2>&1 </dev/null ); rb=$?
    [ -f "$d/out.uhdm" ] && mv "$d/out.uhdm" "$d/b.uhdm"
    ma=NONE; mb=NONE
    [ -f "$d/a.uhdm" ] && ma=$(md5sum "$d/a.uhdm" | cut -d' ' -f1)
    [ -f "$d/b.uhdm" ] && mb=$(md5sum "$d/b.uhdm" | cut -d' ' -f1)
    if [ "$ra" != "$rb" ]; then st=RC-MISMATCH
    elif [ "$ma" = NONE ] && [ "$mb" = NONE ]; then st=NORUN
    elif [ "$ma" = "$mb" ]; then st=SAME
    else st=MOVED; fi
    echo "$st $rel.$view ra=$ra rb=$rb $ma $mb"
    [ "$st" = SAME ] || [ "$st" = NORUN ] && rm -f "$d/a.uhdm" "$d/b.uhdm"
  done
  echo "PROCESSED $rel"
}
export -f run_one; export A B ROOT OUT
xargs -a "$LIST" -d '\n' -I{} -P "$JOBS" bash -c 'run_one "$@"' _ {} > "$OUT/raw.txt" 2>&1
proc=$(grep -c '^PROCESSED ' "$OUT/raw.txt"); true
echo "LISTED=$listed PROCESSED=$proc"
[ "$proc" -eq "$listed" ] || { echo PROCESSED-ASSERT-FAILED; }
echo "MOVED=$(grep -c '^MOVED ' "$OUT/raw.txt"; true)  RC-MISMATCH=$(grep -c '^RC-MISMATCH ' "$OUT/raw.txt"; true)  NORUN=$(grep -c '^NORUN ' "$OUT/raw.txt"; true)  SAME=$(grep -c '^SAME ' "$OUT/raw.txt"; true)"
grep -E '^MOVED |^RC-MISMATCH ' "$OUT/raw.txt" | sort

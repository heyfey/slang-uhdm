#!/usr/bin/env bash
# v58 VERIFIER sweep driver — one verify_golden.py invocation per
# (corpus, mode, LABEL), strictly sequential, --jobs 2, GOLDEN_DEFER unset,
# SLANG_UHDM exported explicitly and READ BACK out of EVERY cmds.txt (never
# `head -1`: the r10earl58 build-race lesson).
#   usage: vsweep58.sh <label> <binary> <csvdir> <wdroot> [corpora...]
set -u
LAB=${1:?label}; BIN=${2:?binary}; CSV=${3:?csv dir}; WD=${4:?workdir root}
shift 4
CORPORA=${*:-uhdm2rtlil surelog}
unset GOLDEN_DEFER
cd "$(dirname "$0")/../../.." || exit 9
echo "REPO ROOT: $PWD"
[ -x "$BIN" ] || { echo "FATAL no binary $BIN"; exit 9; }
echo "BINARY[$LAB] $BIN md5=$(md5sum "$BIN" | cut -d' ' -f1)"
mkdir -p "$CSV" "$WD" || exit 9
for corpus in $CORPORA; do
  for mode in default testflags; do
    out="$CSV/${corpus}_${mode}_${LAB}.csv"
    wdir="$WD/${corpus}_${LAB}"
    echo "=== SWEEP corpus=$corpus mode=$mode label=$LAB -> $out"
    SLANG_UHDM="$BIN" python3 scripts/verify_golden.py --corpus "$corpus" \
      --mode "$mode" --out "$out" --workdir "$wdir" --jobs 2 \
      > "$CSV/${corpus}_${mode}_${LAB}.log" 2>&1
    echo "   exit=$? rows=$(( $(wc -l < "$out") - 1 ))"
  done
  # AUTHORITATIVE binary audit: EVERY cmds.txt, not one.
  tot=0; ok=0
  while IFS= read -r c; do
    n=$(grep -c '^slang:' "$c" 2>/dev/null || true)
    k=$(awk -v b="$BIN" '/^slang:/ && $2==b {n++} END{print n+0}' "$c")
    tot=$((tot+n)); ok=$((ok+k))
  done < <(find "$WD/${corpus}_${LAB}" -name cmds.txt)
  echo "   BINARY AUDIT $corpus/$LAB: slang: lines=$tot naming $BIN=$ok"
done
echo "SWEEPS_DONE $LAB"

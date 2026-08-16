#!/usr/bin/env bash
# r10earl49 VERIFIER — the FOUR sweeps for ONE binary, STRICTLY SEQUENTIAL,
# --jobs 2.  Same traps as sweeps49.sh: SLANG_UHDM is EXPORTED (verify_golden.py
# silently defaults it to the MAIN TREE), GOLDEN_DEFER is unset, and the binary
# each sweep ACTUALLY invoked is read back out of that sweep's own cmds.txt via
# the `slang:` line -- never assumed, never pattern-matched on a `build/` path.
set -u
BIN=${1:?binary}
CSV=${2:?csv dir}
WD=${3:?workdir root}
TAG=${4:?tag}
unset GOLDEN_DEFER
cd /tmp/wt_v49 || exit 9
mkdir -p "$CSV" "$WD" || exit 9
echo "BINARY[$TAG] $BIN md5=$(md5sum "$BIN" | cut -d' ' -f1)"
for corpus in uhdm2rtlil surelog; do
  for mode in default testflags; do
    out="$CSV/${corpus}_${mode}_${TAG}.csv"
    wdir="$WD/${corpus}_${TAG}"
    echo "=== SWEEP corpus=$corpus mode=$mode bin=$TAG -> $out"
    SLANG_UHDM="$BIN" python3 scripts/verify_golden.py --corpus "$corpus" \
      --mode "$mode" --out "$out" --workdir "$wdir" --jobs 2 \
      > "$CSV/${corpus}_${mode}_${TAG}.log" 2>&1
    echo "   exit=$? rows=$(( $(wc -l < "$out") - 1 ))"
    c=$(find "$wdir" -name cmds.txt | head -1)
    [ -n "$c" ] && echo "   cmds.txt binary: $(awk '/^slang:/{print $2; exit}' "$c")"
  done
done
echo ALL_SWEEPS_DONE

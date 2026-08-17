#!/usr/bin/env bash
# r10earl51 — the EIGHT corpus sweeps for gates 3, 4 and 5, STRICTLY
# SEQUENTIAL, --jobs 2, one `verify_golden.py` invocation per
# (corpus, mode, binary).
#
#   usage: sweeps48.sh <patched-bin> <pristine-bin> <csvdir> <wdroot>
#
# TRAPS ENCODED:
#   * verify_golden.py SILENTLY DEFAULTS SLANG_UHDM to the MAIN TREE, so every
#     sweep EXPORTS it and the binary the sweep ACTUALLY invoked is read back
#     out of that sweep's own cmds.txt afterwards -- never assumed.
#   * GOLDEN_DEFER is left UNSET (it is never set here and is unset explicitly
#     below so an inherited value cannot leak in).
#   * One workdir ROOT per (corpus, binary) with the two modes inside it, so
#     the byte verifier sees BOTH modes' databases under one root.
#   * Sequential, never concurrent: concurrent sweeps have a documented
#     SURELOG_FAIL detail-row race.
set -u
PAT=${1:?patched binary}
PRIS=${2:?pristine binary}
CSV=${3:?csv dir}
WD=${4:?workdir root}
unset GOLDEN_DEFER
cd "$(dirname "$0")/../../.." || exit 9
echo "REPO ROOT: $PWD"
mkdir -p "$CSV" "$WD" || exit 9
for b in pat pris; do
  case $b in pat) BIN=$PAT;; pris) BIN=$PRIS;; esac
  echo "BINARY[$b] $BIN md5=$(md5sum "$BIN" | cut -d' ' -f1)"
done
for corpus in ${SWEEP_CORPORA:-uhdm2rtlil surelog}; do
  for b in pat pris; do
    case $b in pat) BIN=$PAT;; pris) BIN=$PRIS;; esac
    for mode in default testflags; do
      out="$CSV/${corpus}_${mode}_${b}.csv"
      wdir="$WD/${corpus}_${b}"
      echo "=== SWEEP corpus=$corpus mode=$mode bin=$b -> $out"
      SLANG_UHDM="$BIN" python3 scripts/verify_golden.py --corpus "$corpus" \
        --mode "$mode" --out "$out" --workdir "$wdir" --jobs 2 \
        > "$CSV/${corpus}_${mode}_${b}.log" 2>&1
      echo "   exit=$? rows=$(( $(wc -l < "$out") - 1 ))"
      # R9 of r10earl46, FIXED HERE: the old line grepped the FIRST
      # `*slang-uhdm` token on the command line, which is the GOLDEN CACHE
      # path, not the binary.  Read back the BUILD binary explicitly.
      c=$(find "$wdir" -name cmds.txt | head -1)
      # R9 of r10earl46 fixed the "first *slang-uhdm token" bug (that was the
      # GOLDEN CACHE path).  r10earl51 fixes the FIX: the replacement pattern
      # assumed the binary lives in a `build/` directory, so a copied/renamed
      # binary read back EMPTY -- a silent loss of the only check that says
      # which binary the sweep actually ran.  Read the `slang:` line's first
      # token, which is the invocation itself, whatever it is called.
      [ -n "$c" ] && echo "   cmds.txt binary: $(awk '/^slang:/{print $2; exit}' "$c")"
      tail -3 "$CSV/${corpus}_${mode}_${b}.log"
    done
  done
done
echo ALL_SWEEPS_DONE

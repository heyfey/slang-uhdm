#!/usr/bin/env bash
# r10uvm90 — sweep driver.  ONE harness (scripts/verify_golden.py), --jobs 2, my
# OWN --out/--workdir, and the three ops guards this campaign has paid for:
#   * GOLDEN_DEFER is ECHOED before the run and must read [UNSET];
#   * SLANG_UHDM is EXPORTED to the binary under test and the workdir's own
#     cmds.txt is grepped afterwards for the BINARY PATH (grepping for
#     `slang-uhdm` proves nothing -- that substring also matches the golden
#     cache dirs `slang-uhdm-goldens/...`);
#   * results/*.csv are never written -- the CSV goes to /tmp.
#   usage: sweep89.sh <binary> <corpus> <tag>
set -u
BIN=${1:?binary}
CORPUS=${2:?surelog|uhdm2rtlil}
TAG=${3:?tag}
REPO=${REPO:-/tmp/wt_r10uvm90}
OUT=/tmp/r10uvm90_${TAG}_${CORPUS}.csv
WD=/tmp/r10uvm90_wd_${TAG}_${CORPUS}
echo "GOLDEN_DEFER=[${GOLDEN_DEFER:-UNSET}]"
echo "BIN=$BIN md5=$(md5sum "$BIN" | cut -d' ' -f1)"
export SLANG_UHDM="$BIN"
rm -rf "$WD"; mkdir -p "$WD"
python3 "$REPO/scripts/verify_golden.py" --corpus "$CORPUS" --mode both \
  --jobs 2 --out "$OUT" --workdir "$WD" 2>&1 | tail -25
echo "-- cmds.txt BINARY-PATH check (the path, not the substring):"
grep -rhoF "$BIN" "$WD" --include=cmds.txt | sort | uniq -c | head
echo "-- rows: $(($(wc -l < "$OUT") - 1))  OUT=$OUT WD=$WD"

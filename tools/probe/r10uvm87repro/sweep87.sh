#!/usr/bin/env bash
# r10uvm87 — sweep driver.  ONE harness (scripts/verify_golden.py), --jobs 2,
# my OWN --out/--workdir, and three ops guards this campaign has paid for:
#   * GOLDEN_DEFER is ECHOED before the run and must read [UNSET];
#   * SLANG_UHDM is EXPORTED to the binary under test and the workdir's own
#     cmds.txt is grepped afterwards to prove THAT binary is the one that ran;
#   * results/*.csv are never written — the CSV goes to /tmp.
#
#   usage: sweep87.sh <binary> <corpus> <tag>
set -u
BIN=${1:?binary}
CORPUS=${2:?surelog|uhdm2rtlil}
TAG=${3:?tag}
REPO=${REPO:-/tmp/wt_r10uvm87}
OUT=/tmp/r10uvm87_${TAG}_${CORPUS}.csv
WD=/tmp/r10uvm87_wd_${TAG}_${CORPUS}
echo "GOLDEN_DEFER=[${GOLDEN_DEFER:-UNSET}]"
echo "BIN=$BIN md5=$(md5sum "$BIN" | cut -d' ' -f1)"
export SLANG_UHDM="$BIN"
rm -rf "$WD"; mkdir -p "$WD"
python3 "$REPO/scripts/verify_golden.py" --corpus "$CORPUS" --mode both \
  --jobs 2 --out "$OUT" --workdir "$WD" 2>&1 | tail -25
echo "-- cmds.txt binary check:"
grep -rhoE "[^ ]*slang-uhdm" "$WD" --include=cmds.txt | sort | uniq -c | head
echo "-- rows: $(($(wc -l < "$OUT") - 1))  OUT=$OUT WD=$WD"

#!/usr/bin/env bash
# r10rgg2/run_rgg2.sh — take one arm against REAL Surelog and (optionally) a
# slang-uhdm binary, and print every function-body constant with its value.
#
#   usage: [SLANG=<slang-uhdm>] ./run_rgg2.sh <outdir> <arm-basename> [top]
#
# GUARD: a side that produced no dump prints UNMEASURED and the script exits
# non-zero — a run that measured nothing must never read as agreement.
set -u
OUT=${1:?outdir}; ARM=${2:?arm basename}; TOP=${3:-$ARM}
SL=~/git-repos/Surelog/build/bin/surelog
DUMP=~/git-repos/UHDM/build/bin/uhdm-dump
here=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$OUT/$ARM" || exit 1
cd "$OUT/$ARM" || exit 1
cp "$here/$ARM.sv" .
"$SL" -parse -nopython -d uhdm -top "$TOP" "$ARM.sv" > gold.dump 2> gold.err
rc=$?
n=$(grep -c '_constant: ' gold.dump 2>/dev/null || true)
echo "surelog $ARM rc=$rc constants=$n"
if [ "${n:-0}" -eq 0 ]; then echo "UNMEASURED golden $ARM"; exit 3; fi
if [ -n "${SLANG:-}" ]; then
  "$SLANG" --single-unit --top "$TOP" "$ARM.sv" -o ours.uhdm > ours.log 2>&1
  echo "slang   $ARM rc=$?"
  "$DUMP" ours.uhdm > ours.dump 2>&1
  m=$(grep -c '_constant: ' ours.dump 2>/dev/null || true)
  echo "ours constants=$m"
  [ "${m:-0}" -eq 0 ] && { echo "UNMEASURED ours $ARM"; exit 4; }
fi
exit 0

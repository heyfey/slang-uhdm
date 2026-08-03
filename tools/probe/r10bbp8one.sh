#!/bin/bash
# r10bbp8one: run ONE corpus test and diff all three CMP-relevant projections
# (param_assign summary / parameter fields / Rhs-operation OPERANDS) between
# golden and ours.  The operand projection is the one that caught the Kmac
# KeccakRate width residue — the summary projections cannot see it.
#   usage: r10bbp8one.sh <corpus> <mode> <TestName> [head-lines]
W=${W:-$PWD}
export SLANG_UHDM=$W/build/slang-uhdm
cd "$W" || exit 1
C=$1; M=$2; T=$3; N=${4:-20}
rm -rf /tmp/r10bbp8_1w
python3 scripts/verify_golden.py --corpus "$C" --mode "$M" --filter "^$T\$" \
  --out /tmp/r10bbp8_1.csv --workdir /tmp/r10bbp8_1w --jobs 1 2>&1 | tail -2
cat /tmp/r10bbp8_1.csv
D=$(find /tmp/r10bbp8_1w -maxdepth 2 -type d -name "$T-*" | head -1)
G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[a-f0-9]*" "$D/cmds.txt" | head -1)/golden.uhdm
echo "golden=$G"
for p in d p o; do
  [ -x /tmp/r10bbp8${p}q ] || continue
  /tmp/r10bbp8${p}q "$G" > /tmp/r10bbp8_${p}g.txt
  /tmp/r10bbp8${p}q "$D/slang.uhdm" > /tmp/r10bbp8_${p}s.txt
  echo "== probe $p difflines=$(diff /tmp/r10bbp8_${p}g.txt /tmp/r10bbp8_${p}s.txt | grep -c '^[<>]')"
  diff /tmp/r10bbp8_${p}g.txt /tmp/r10bbp8_${p}s.txt | head -$N
done

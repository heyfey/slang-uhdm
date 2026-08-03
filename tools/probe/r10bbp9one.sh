#!/bin/bash
# r10bbp9one: run ONE corpus test and diff the CMP-relevant param_assign
# census (r10bbp7d projection, built as /tmp/r10bbp9dq) between golden and
# ours.  Set W to the worktree root.
#   usage: r10bbp9one.sh <corpus> <mode> <TestName> [head-lines]
W=${W:-$PWD}
export SLANG_UHDM=$W/build/slang-uhdm
cd "$W" || exit 1
C=$1; M=$2; T=$3; N=${4:-30}
rm -rf /tmp/r10bbp9_1w
python3 scripts/verify_golden.py --corpus "$C" --mode "$M" --filter "^$T\$" \
  --out /tmp/r10bbp9_1.csv --workdir /tmp/r10bbp9_1w --jobs 1 2>&1 | tail -2
cat /tmp/r10bbp9_1.csv
D=$(find /tmp/r10bbp9_1w -maxdepth 2 -type d -name "$T-*" | head -1)
G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[a-f0-9]*" "$D/cmds.txt" | head -1)/golden.uhdm
echo "golden=$G"
echo "$G" > /tmp/r10bbp9_1g.path
echo "$D/slang.uhdm" > /tmp/r10bbp9_1s.path
/tmp/r10bbp9dq "$G" > /tmp/r10bbp9_1gd.txt
/tmp/r10bbp9dq "$D/slang.uhdm" > /tmp/r10bbp9_1sd.txt
echo "== census difflines=$(diff /tmp/r10bbp9_1gd.txt /tmp/r10bbp9_1sd.txt | grep -c '^[<>]')"
diff /tmp/r10bbp9_1gd.txt /tmp/r10bbp9_1sd.txt | head -$N

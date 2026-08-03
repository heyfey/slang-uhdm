#!/bin/bash
# r10bbp9run: re-run BlackBePipeInt and diff the CMP-relevant param_assign
# census (r10bbp7d projection, built as /tmp/r10bbp9dq) between golden and
# ours.  Set W to the worktree root.
#   usage: r10bbp9run.sh [mode] [head-lines]
W=${W:-$PWD}
export SLANG_UHDM=$W/build/slang-uhdm
rm -rf /tmp/r10bbp9_tw
python3 $W/scripts/verify_golden.py --corpus surelog --mode ${1:-default} \
  --filter '^BlackBePipeInt$' --out /tmp/r10bbp9_t.csv \
  --workdir /tmp/r10bbp9_tw --jobs 1 2>&1 | tail -3
cat /tmp/r10bbp9_t.csv
S=$(find /tmp/r10bbp9_tw -name slang.uhdm | head -1)
echo "$S" > /tmp/r10bbp9_slang.path
D=$(dirname "$S")
G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[a-f0-9]*" "$D/cmds.txt" | head -1)/golden.uhdm
echo "$G" > /tmp/r10bbp9_gold.path
/tmp/r10bbp9dq "$G" > /tmp/r10bbp9_gd.txt
/tmp/r10bbp9dq "$S" > /tmp/r10bbp9_sd.txt
echo "== param_assign census diff: $(diff /tmp/r10bbp9_gd.txt /tmp/r10bbp9_sd.txt | grep -c '^[<>]')"
diff /tmp/r10bbp9_gd.txt /tmp/r10bbp9_sd.txt | grep '^<' | awk '{print $2}' | sort | uniq -c
diff /tmp/r10bbp9_gd.txt /tmp/r10bbp9_sd.txt | head -${2:-20}

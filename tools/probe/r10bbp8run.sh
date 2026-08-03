#!/bin/bash
# r10bbp8run: re-run BlackBePipeInt and diff the CMP-relevant param_assign
# census (r10bbp7d) between golden and ours.  Set W to the worktree root.
#   usage: r10bbp8run.sh [mode] [head-lines]
W=${W:-$PWD}
export SLANG_UHDM=$W/build/slang-uhdm
rm -rf /tmp/r10bbp8_tw
python3 $W/scripts/verify_golden.py --corpus surelog --mode ${1:-default} \
  --filter '^BlackBePipeInt$' --out /tmp/r10bbp8_t.csv \
  --workdir /tmp/r10bbp8_tw --jobs 1 2>&1 | tail -3
cat /tmp/r10bbp8_t.csv
S=$(find /tmp/r10bbp8_tw -name slang.uhdm | head -1)
echo "$S" > /tmp/r10bbp8_slang.path
G=$HOME/.cache/slang-uhdm-goldens/c1bcb145248f6aa019f1/golden.uhdm
/tmp/r10bbp8dq "$G" > /tmp/r10bbp8_gd.txt
/tmp/r10bbp8dq "$S" > /tmp/r10bbp8_sd.txt
echo "== param_assign census diff: $(diff /tmp/r10bbp8_gd.txt /tmp/r10bbp8_sd.txt | grep -c '^[<>]')"
diff /tmp/r10bbp8_gd.txt /tmp/r10bbp8_sd.txt | grep '^<' | awk '{print $2}' | sort | uniq -c
diff /tmp/r10bbp8_gd.txt /tmp/r10bbp8_sd.txt | head -${2:-20}

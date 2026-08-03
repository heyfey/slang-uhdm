#!/bin/bash
# r10bbp5: re-run BlackBePipeInt (default mode), re-census, re-cmp.
set -e
W=/home/heyfey/git-repos/slang-uhdm/.claude/worktrees/wf_16fae455-d00-1
export SLANG_UHDM=$W/build/slang-uhdm
G=/home/heyfey/.cache/slang-uhdm-goldens/c1bcb145248f6aa019f1/golden.uhdm
rm -rf /tmp/r10bbp5_tw
python3 $W/scripts/verify_golden.py --corpus surelog --mode default \
  --filter '^BlackBePipeInt$' --out /tmp/r10bbp5_t.csv \
  --workdir /tmp/r10bbp5_tw --jobs 1 2>&1 | tail -3
S=$(find /tmp/r10bbp5_tw -name slang.uhdm | head -1)
echo "slang=$S"
/tmp/r10bbp5pq "$S" > /tmp/r10bbp5_s.txt
sed 's/#[0-9]*//' /tmp/r10bbp5_s.txt > /tmp/r10bbp5_sn.txt
diff /tmp/r10bbp5_gn.txt /tmp/r10bbp5_sn.txt > /tmp/r10bbp5_census.diff || true
echo "CENSUS_DIFF $(wc -l < /tmp/r10bbp5_census.diff)"
grep -E '^(ALLPKG|TOPPKG)/' /tmp/r10bbp5_sn.txt > /tmp/r10bbp5_spkg.txt
diff /tmp/r10bbp5_gpkg.txt /tmp/r10bbp5_spkg.txt > /tmp/r10bbp5_pkg.diff || true
echo "PKG_DIFF $(wc -l < /tmp/r10bbp5_pkg.diff)"
timeout 900 /tmp/r10bbp5_ct "$G" "$S" 2>/dev/null

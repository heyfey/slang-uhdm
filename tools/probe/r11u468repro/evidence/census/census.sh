#!/bin/bash
# traced census of the law binary (prediction before the sweep)
cd /tmp/wt_r11u468 || exit 1
source tools/probe/r11u468repro/drivers/env.sh || exit 1
export SLANG_UHDM=/tmp/r11u468_bin/law13
[ -x "$SLANG_UHDM" ] || exit 1
C=/tmp/r11u468_census; mkdir -p $C/trace
export R11U468_TRACE=$C/trace
date > $C/start.txt
NOF=$(python3 -c "import re;n=[l.strip() for l in open('/tmp/r11u468_scratch/fenced.txt') if l.strip()];print('^(?!(' + '|'.join(re.escape(x) for x in n) + ')$)')")
python3 scripts/verify_golden.py --corpus uhdm2rtlil --mode both --jobs 3 --filter "$NOF" --out $C/u2r.csv --workdir $C/u2r > $C/u2r.log 2>&1
python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 3 --filter "$NOF" --out $C/sl.csv --workdir $C/sl > $C/sl.log 2>&1
python3 scripts/check_probe.py --jobs 3 --workdir $C/probe --out $C/probe.csv > $C/probe.log 2>&1
python3 scripts/svtests/svtests_matrix.py --svtests /home/heyfey/git-repos/sv-tests --out $C/sv.csv --workroot $C/sv --jobs 3 --paths-file /tmp/r11u468_scratch/sv_cand.txt --uvm-dir /home/heyfey/git-repos/slang-uhdm/third_party/Surelog/third_party/UVM/1800.2-2017-1.0 > $C/sv.log 2>&1
date > $C/done.txt

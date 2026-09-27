#!/bin/bash
# r11u186: the determinism measurement of § lawSCopyIdOrder186: N concurrent harness runs of one corpus row-mode
# with one binary (verify_golden.py --filter '^<row>$', its own workdir each), then the md5 of each database.
# usage: det.sh <binary name under /tmp/r11u186_bin> <row> <mode> [N=3]   (refuses the fenced names)
. /tmp/wt_r11u186/tools/probe/r11u186repro/drivers/env.sh || exit 3
B=$1; R=$2; M=$3; N=${4:-3}
for f in $FENCED; do [ "$R" = "$f" ] && { echo "det.sh: fenced row refused" >&2; exit 3; }; done
export SLANG_UHDM=/tmp/r11u186_bin/$B
cd /tmp/wt_r11u186
for i in $(seq 1 $N); do
  W=/tmp/r11u186_det/$B/$R.$M.$i; rm -rf $W; mkdir -p $W
  python3 scripts/verify_golden.py --corpus surelog --mode $M --jobs 1 --filter "^$R\$" --out $W/o.csv --workdir $W/w > $W/log 2>&1 &
done
wait
for i in $(seq 1 $N); do W=/tmp/r11u186_det/$B/$R.$M.$i; f=$(find $W/w -name slang.uhdm | head -1); echo "$B $R $M run$i $(md5sum < $f | cut -c1-12) $(tail -1 $W/o.csv | cut -d, -f3,6)"; done

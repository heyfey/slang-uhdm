#!/bin/bash
# v11u188: det.sh <binary name under $V188_BIN> <row> <mode> [N=3]: N concurrent harness runs of one surelog-corpus
# row-mode (verify_golden.py --filter '^<row>$', own workdir each), then the md5 of each database.  Refuses fenced rows.
. "$(dirname "$0")/env.sh" || exit 9
B=$1; R=$2; M=$3; N=${4:-3}
v188_fenced "$R" && { echo "det.sh: fenced row refused" >&2; exit 9; }
export SLANG_UHDM=$V188_BIN/$B
cd "$V188_REPO"
for i in $(seq 1 $N); do
  W=${V188_DET:-/tmp/v11u188_det}/$B/$R.$M.$i; rm -rf $W; mkdir -p $W
  python3 scripts/verify_golden.py --corpus surelog --mode $M --jobs 1 --filter "^$R\$" --out $W/o.csv --workdir $W/w > $W/log 2>&1 &
done
wait
for i in $(seq 1 $N); do W=${V188_DET:-/tmp/v11u188_det}/$B/$R.$M.$i; f=$(find $W/w -name slang.uhdm | head -1); echo "$B $R $M run$i $(md5sum < $f | cut -c1-12) $(tail -1 $W/o.csv | cut -d, -f3,6)"; done

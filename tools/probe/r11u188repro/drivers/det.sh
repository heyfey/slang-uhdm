#!/bin/bash
# r11u188 (from r11u186repro): the determinism measurement (caution j): N concurrent harness runs of one corpus row-mode
# with one binary (verify_golden.py --filter '^<row>$', its own workdir each), then the md5 of each database.
# usage: det.sh <binary name under $R188_BIN> <row> <mode> [N=3]   (refuses the fenced names)
. "$(dirname "$0")/env.sh" || exit 3
B=$1; R=$2; M=$3; N=${4:-3}
for f in $FENCED; do [ "$R" = "$f" ] && { echo "det.sh: fenced row refused" >&2; exit 3; }; done
export SLANG_UHDM=$R188_BIN/$B
cd "$R188_REPO"
for i in $(seq 1 $N); do
  W=${R188_DET:-/tmp/r11u188_det}/$B/$R.$M.$i; rm -rf $W; mkdir -p $W
  python3 scripts/verify_golden.py --corpus surelog --mode $M --jobs 1 --filter "^$R\$" --out $W/o.csv --workdir $W/w > $W/log 2>&1 &
done
wait
for i in $(seq 1 $N); do W=${R188_DET:-/tmp/r11u188_det}/$B/$R.$M.$i; f=$(find $W/w -name slang.uhdm | head -1); echo "$B $R $M run$i $(md5sum < $f | cut -c1-12) $(tail -1 $W/o.csv | cut -d, -f3,6)"; done

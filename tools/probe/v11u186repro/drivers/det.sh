#!/bin/bash
# usage: det.sh <bin name> <row> <mode> [N]
. /tmp/v11u186_env.sh || exit 3
B=$1; R=$2; M=$3; N=${4:-3}
for f in $FENCED; do [ "$R" = "$f" ] && { echo "fenced row refused" >&2; exit 3; }; done
export SLANG_UHDM=$VB/$B
cd /tmp/wt_v11u186pris
for i in $(seq 1 $N); do
  W=/tmp/v11u186_det/$B/$R.$M.$i; rm -rf $W; mkdir -p $W
  python3 scripts/verify_golden.py --corpus surelog --mode $M --jobs 1 --filter "^$R\$" --out $W/o.csv --workdir $W/w > $W/log 2>&1 &
done
wait
for i in $(seq 1 $N); do W=/tmp/v11u186_det/$B/$R.$M.$i; f=$(find $W/w -name slang.uhdm | head -1); c=$(grep -o "slang: *[^ ]*" $(find $W/w -name cmds.txt | head -1) | head -1); echo "$B $R $M run$i $(md5sum < $f | cut -c1-12) $(tail -1 $W/o.csv | cut -d, -f3,6) [$c]"; done

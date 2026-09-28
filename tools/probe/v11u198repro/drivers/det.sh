#!/bin/bash
# v11u198 (copied from r11u198repro): the determinism control.  Three CONCURRENT harness runs of one binary over the named surelog rows (both
# modes), each into its own same-length workdir, then the md5 of every slang.uhdm per row-mode across the three runs.
# usage: det.sh <binary name in $VB> <out dir> <test>...   (refuses a fenced name; FENCED from env.sh, fail closed)
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
REPO=$(cd "$HERE/../../../.." && pwd); BIN=$1; O=$2; shift 2
for t in "$@"; do for f in $FENCED; do [ "$t" = "$f" ] && { echo "det: fenced test refused" >&2; exit 3; }; done; done
F="^($(echo "$@" | tr ' ' '|'))$"
mkdir -p $O; cd $REPO
for k in 1 2 3; do
  SLANG_UHDM=$VB/$BIN STRICT_CMP=$SCMP python3 scripts/verify_golden.py --corpus surelog --mode both --jobs 1 --filter "$F" \
    --out $O/run$k.csv --workdir $O/w$k > $O/run$k.log 2>&1 &
done
wait
for k in 1 2 3; do (cd $O/w$k && find . -name slang.uhdm | sort | xargs md5sum | sed "s#/slang.uhdm##; s#-[0-9a-f]\{8\}##") > $O/md5_$k.txt; done
paste $O/md5_1.txt $O/md5_2.txt $O/md5_3.txt | awk '{s=($1==$3&&$3==$5)?"SAME":"DIFF"; print $2, s, substr($1,1,12), substr($3,1,12), substr($5,1,12)}'

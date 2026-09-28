#!/bin/bash
# v11u210 (after r11u210 drivers/det.sh): three CONCURRENT harness runs of one binary over the named rows of one corpus
# (both modes), each into its own same-length workdir; prints the md5 of every slang.uhdm per row-mode across the three
# runs. STRICT_CMP=/bin/true (the hashes need no comparator). usage: det.sh <binary> <corpus> <outdir> <test>...
REPO=/home/heyfey/git-repos/slang-uhdm
FENCED="$(grep -m1 '^FENCED=' "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "det: fence unreadable" >&2; exit 3; }
BIN=$1; C=$2; O=$3; shift 3
for t in "$@"; do for f in $FENCED; do [ "$t" = "$f" ] && { echo "det: fenced test refused" >&2; exit 3; }; done; done
F="^($(echo "$@" | tr ' ' '|'))$"; mkdir -p $O; cd /tmp/wt_v11u210
for k in 1 2 3; do
  SLANG_UHDM=$BIN STRICT_CMP=/bin/true python3 scripts/verify_golden.py --corpus $C --mode both --jobs 1 --filter "$F" \
    --out $O/run$k.csv --workdir $O/w$k > $O/run$k.log 2>&1 &
done
wait
for k in 1 2 3; do (cd $O/w$k && find . -name slang.uhdm | sort | xargs md5sum | sed "s#/slang.uhdm##; s#-[0-9a-f]\{8\}##") > $O/md5_$k.txt; done
paste $O/md5_1.txt $O/md5_2.txt $O/md5_3.txt | awk '{s=($1==$3&&$3==$5)?"SAME":"DIFF"; print $2, s, substr($1,1,12), substr($3,1,12), substr($5,1,12)}'

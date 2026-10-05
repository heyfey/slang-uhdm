#!/bin/bash
# (v11u238) det2.sh <binary> <tag> <rounds> <mode> <row...>: <rounds> rounds of three CONCURRENT verify_golden.py runs of the
# binary on the named rows in one mode; prints, per row, the hash histogram of slang.uhdm. Fenced rows refused (fail-closed).
[ -n "$FENCED" ] && [ -n "$S" ] || { echo "det2.sh: source drivers/env.sh" >&2; exit 2; }
HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
BIN=$1; TAG=$2; N=$3; M=$4; shift 4; T="$*"
[ -x "$BIN" ] || { echo "det2.sh: binary not executable" >&2; exit 2; }
for t in $T; do for f in $FENCED; do [ "$f" = "$t" ] && { echo "det2.sh: fenced row refused" >&2; exit 2; }; done; done
FIL="^($(echo $T | tr ' ' '|'))$"
cd $REPO
for r in $(seq 1 $N); do
  for i in 1 2 3; do rm -rf $S/d2_${TAG}_$r$i; SLANG_UHDM=$BIN python3 scripts/verify_golden.py --corpus surelog --mode $M --jobs 2 --filter "$FIL" --out $S/d2_${TAG}_$r$i.csv --workdir $S/d2_${TAG}_$r$i > $S/d2_${TAG}_$r$i.log 2>&1 & done; wait
done
for t in $T; do
  hs=$(for d in $S/d2_${TAG}_*; do [ -d $d ] && md5sum $d/$M/$t-*/slang.uhdm 2>/dev/null | cut -c1-12; done | sort | uniq -c | tr '\n' ' ')
  echo "$TAG $t/$M $hs"
done

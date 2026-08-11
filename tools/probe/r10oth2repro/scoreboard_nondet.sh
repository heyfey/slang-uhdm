#!/usr/bin/env bash
# Is the UVM Scoreboard `default` database a CHANGE, or the known intermittent
# nondeterminism?  Test: run the SAME binary 4 times and see whether its own
# output varies.  Then do the same for the PRISTINE binary.
set -u
# SLANG_UHDM = the build under test; PRISTINE_UHDM = a binary built from the base
# commit.  Neither has a default: measuring the wrong binary is indistinguishable
# from a pass (scripts/verify_golden.py:52 and tests/check_goldens.sh:5 both
# default to the MAIN-TREE binary).
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
: "${PRISTINE_UHDM:?set PRISTINE_UHDM to a base-commit build}"
W=${W:-$(cd "$(dirname "$0")/../../.." && pwd)}
SCR=${SCR:-/tmp/r10oth2_sb}
mkdir -p $SCR
cd $W
run() {  # run <binary> <tag> <n>
  SLANG_UHDM=$1 python3 scripts/verify_golden.py --corpus surelog --mode default \
     --out $SCR/sb_$2$3.csv --workdir $SCR/wd_sb --jobs 2 \
     --filter '^Scoreboard$' >/dev/null 2>&1
  local f=$SCR/wd_sb/default/Scoreboard-*/slang.uhdm
  cp $f $SCR/sb_$2$3.uhdm
  echo "  $2 run$3: $(md5sum $SCR/sb_$2$3.uhdm | cut -d' ' -f1)"
}
echo "FINAL binary ($(md5sum $SLANG_UHDM | cut -d' ' -f1)):"
for i in 1 2 3 4; do run $SLANG_UHDM final $i; done
echo "PRISTINE binary ($(md5sum $PRISTINE_UHDM | cut -d' ' -f1)):"
for i in 1 2 3 4; do run $PRISTINE_UHDM pri $i; done
echo "=== distinct outputs per binary:"
echo -n "  final:    "; md5sum $SCR/sb_final*.uhdm | cut -d' ' -f1 | sort -u | wc -l
echo -n "  pristine: "; md5sum $SCR/sb_pri*.uhdm  | cut -d' ' -f1 | sort -u | wc -l
echo "=== do the two binaries' output SETS overlap?"
comm -12 <(md5sum $SCR/sb_final*.uhdm | cut -d' ' -f1 | sort -u) \
         <(md5sum $SCR/sb_pri*.uhdm | cut -d' ' -f1 | sort -u) | \
  sed 's/^/  shared md5: /'

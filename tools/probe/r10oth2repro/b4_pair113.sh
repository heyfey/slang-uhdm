#!/usr/bin/env bash
# r10oth2 DIRECTION B bisector step.  Compiles ONLY the two source files that
# both carry a line 113 `output [dw-1:0] ...;` port range -- or1200_du.v and
# or1200_ic_top.v -- together with the union of their dependencies, and counts
# the FOLDED vs UNFOLDED forms of the line-113 bound in BOTH databases.
#
# r10oth1 proved each file alone is PASS_CMP and reproduces golden's def/elab
# split exactly, so if this PAIR already loses one unfolded object then the
# defect is object sharing between these two modules and the search is over a
# 2-file design instead of an 80-file one.
#
# LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
# SLANG_UHDM must be set -- there is deliberately no default, because
# scripts/verify_golden.py and tests/check_goldens.sh both fall back to the
# MAIN-TREE binary and a wrong-binary measurement is indistinguishable from a
# pass.
set -u
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
R=${OR1200_RTL:-$HOME/git-repos/Surelog/third_party/tests/YosysOldTests/or1200/rtl}
D=${1:-/tmp/r10oth2_b4}
rm -rf "$D"; mkdir -p "$D" || exit 9
cd "$D" || exit 9
FILES="or1200_defines.v timescale.v or1200_du.v or1200_ic_top.v or1200_ic_fsm.v \
or1200_ic_ram.v or1200_ic_tag.v or1200_spram.v or1200_spram_1024x32.v \
or1200_spram_2048x32.v or1200_spram_256x21.v or1200_spram_512x20.v \
or1200_spram_64x14.v or1200_spram_64x22.v or1200_spram_64x24.v \
or1200_spram_32x24.v or1200_spram_1024x8.v or1200_spram_2048x8.v \
or1200_spram_128x32.v or1200_spram_32_bw.v or1200_spram_1024x32_bw.v \
or1200_spram_2048x32_bw.v"
for f in $FILES; do cp "$R/$f" . 2>/dev/null; done
"$SURELOG" -parse -nobuiltin -nocache +incdir+. $FILES -single-unit \
    >surelog.log 2>&1
[ -f slpp_all/surelog.uhdm ] || { echo SURELOG_FAIL; tail -5 surelog.log; exit 5; }
"$SLANG_UHDM" +incdir+. $FILES --single-unit --nobuiltin -o slang.uhdm \
    >slang.log 2>&1; echo "slang rc=$?"
# uhdm-cmp EXITS 0 ON A MISSING INPUT FILE ("File does not exist!"), so this
# guard is what stops the next line printing PASS_CMP on nothing.
[ -f slang.uhdm ] || { echo NO_OUTPUT; tail -8 slang.log; exit 6; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump
"$DUMP" slang.uhdm 2>/dev/null | sed '1d' > o.dump
for side in g o; do
  lbl=golden; [ $side = o ] && lbl=ours
  echo -n "$lbl UNFOLDED op 113:9-13 objects : "
  grep -c "operation: , line:113:9, endln:113:13" $side.dump
  echo -n "$lbl FOLDED const 113:9-11 objects: "
  grep -c "constant: , line:113:9, endln:113:11" $side.dump
done
"$CMP" slpp_all/surelog.uhdm slang.uhdm >cmp.log 2>&1 && echo PASS_CMP || \
  { echo CMP_FAIL; head -12 cmp.log; }
echo "WD=$D"

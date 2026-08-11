#!/usr/bin/env bash
# CORRECTED BY THE PASS-47-ERA VERIFIER AUDIT.  This script hard-coded the
# implementing agent's own worktree binary and cd'd into a scratchpad directory
# it never created, so it could not be re-run from the patch alone and it
# measured a path that disappears on worktree cleanup -- precisely the
# wrong-binary trap the campaign brief names.  It now takes the binary from
# SLANG_UHDM (unset = hard error, never a silent fall-back to the main tree) and
# stages its own sources.
set -u
: "${SLANG_UHDM:?set SLANG_UHDM to the build under test}"
SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
DUMP=${UHDM_DUMP:-$HOME/.local/bin/uhdm-dump}
CMP=${UHDM_CMP:-$HOME/.local/bin/uhdm-cmp}
R=${OR1200_RTL:-$HOME/git-repos/Surelog/third_party/tests/YosysOldTests/or1200/rtl}
D=${1:-/tmp/r10oth1_b2}
mkdir -p "$D" || exit 9
cd "$D" || exit 9
FILES="or1200_defines.v timescale.v or1200_ic_top.v or1200_ic_fsm.v or1200_ic_ram.v or1200_ic_tag.v or1200_spram.v or1200_spram_1024x32.v or1200_spram_2048x32.v or1200_spram_256x21.v or1200_spram_512x20.v or1200_spram_64x14.v or1200_spram_64x22.v or1200_spram_64x24.v or1200_spram_32x24.v or1200_spram_1024x8.v or1200_spram_2048x8.v or1200_spram_128x32.v or1200_spram_32_bw.v or1200_spram_1024x32_bw.v or1200_spram_2048x32_bw.v"
for f in $FILES; do cp "$R/$f" .; done
"$SURELOG" -parse -nobuiltin -nocache \
   +incdir+. $FILES -single-unit >surelog.log 2>&1
ls slpp_all/surelog.uhdm >/dev/null || { tail -3 surelog.log; exit 5; }
"$SLANG_UHDM" +incdir+. $FILES --single-unit --nobuiltin \
   -o slang.uhdm >slang.log 2>&1; echo "slang rc=$?"
[ -f slang.uhdm ] || { tail -5 slang.log; exit 6; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump
"$DUMP" slang.uhdm 2>/dev/null | sed '1d' > o.dump
echo -n "golden unfolded op@113:9 : "; grep -c "operation: , line:113:9, endln:113:13" g.dump
echo -n "ours   unfolded op@113:9 : "; grep -c "operation: , line:113:9, endln:113:13" o.dump
echo -n "golden folded const@113:9: "; grep -c "constant: , line:113:9, endln:113:11" g.dump
echo -n "ours   folded const@113:9: "; grep -c "constant: , line:113:9, endln:113:11" o.dump
"$CMP" slpp_all/surelog.uhdm slang.uhdm >cmp.log 2>&1 &&
  echo PASS_CMP || { echo CMP_FAIL; head -20 cmp.log; }

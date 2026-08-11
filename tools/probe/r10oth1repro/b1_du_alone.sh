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
D=${1:-/tmp/r10oth1_b1}
mkdir -p "$D" || exit 9
for f in or1200_defines.v or1200_du.v timescale.v; do cp "$R/$f" "$D/"; done
cd "$D" || exit 9
"$SURELOG" -parse -nobuiltin -nocache \
   +incdir+. or1200_defines.v or1200_du.v -single-unit >surelog.log 2>&1
ls slpp_all/surelog.uhdm || { tail -3 surelog.log; exit 5; }
"$SLANG_UHDM" +incdir+. or1200_defines.v or1200_du.v --single-unit \
   --nobuiltin -o slang.uhdm >slang.log 2>&1; echo "slang rc=$?"
[ -f slang.uhdm ] || { echo "NO_OUTPUT (slang produced no database -- uhdm-cmp\n  EXITS 0 on a missing input, so without this guard the next line would\n  print PASS_CMP on nothing.  Measured by the pass-47-era verifier.)";\n  tail -5 slang.log 2>/dev/null; exit 6; }
"$DUMP" slpp_all/surelog.uhdm 2>/dev/null | sed '1d' > g.dump
"$DUMP" slang.uhdm 2>/dev/null | sed '1d' > o.dump
echo -n "golden unfolded op@113:9 : "; grep -c "operation: , line:113:9, endln:113:13" g.dump
echo -n "ours   unfolded op@113:9 : "; grep -c "operation: , line:113:9, endln:113:13" o.dump
echo -n "golden folded const@113:9: "; grep -c "constant: , line:113:9, endln:113:11" g.dump
echo -n "ours   folded const@113:9: "; grep -c "constant: , line:113:9, endln:113:11" o.dump
"$CMP" slpp_all/surelog.uhdm slang.uhdm >cmp.log 2>&1 &&
  echo PASS_CMP || echo "CMP_FAIL"
head -12 cmp.log

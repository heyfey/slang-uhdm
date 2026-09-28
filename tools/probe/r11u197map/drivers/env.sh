# r11u197map: the pins, the frozen binaries and the fence. Source it: `. drivers/env.sh`.
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export B=/tmp/r11u197_bin WT=/tmp/wt_r11u197 W=/tmp/r11u197_W H=/tmp/intr11u194
export SLANG_UHDM=${SLANG_UHDM:-/tmp/r11u197_bin/slang-uhdm} STRICT_CMP=/tmp/r11u197_bin/uhdm-strictcmp
# The four slang-fenced names come from the FENCED= line of tools/probe/r11u107repro/canaudit.sh (never spelled here,
# never read from RESUME.md by line number). Fail closed.
export FENCED="$(grep -m1 '^FENCED=' /tmp/wt_r11u197/tools/probe/r11u107repro/canaudit.sh | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }

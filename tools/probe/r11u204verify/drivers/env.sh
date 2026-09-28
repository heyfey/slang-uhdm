# r11u204 environment: pinned tools, frozen binaries, the fence list read from the FENCED= line of
# tools/probe/r11u107repro/canaudit.sh of THIS checkout (resolved from this file's path; never spelled here, never read
# from RESUME.md).  Fail closed: refuses without four names.  (Adapted from r11u199verify/drivers/env.sh.)
R204_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"; export R204_ROOT
export R204_DIR=$R204_ROOT/tools/probe/r11u204verify
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export R204_BIN=${R204_BIN:-/tmp/r11u204_bin}
export STRICT_CMP=${STRICT_CMP:-$R204_BIN/uhdm-strictcmp}
export LAW=${LAW:-$R204_BIN/law.bin}     # 1454b68c (HEAD, passes 196 and 198 landed) = the main tree's build/slang-uhdm (18183f058868)
export FIX=${FIX:-$R204_BIN/fix.bin}     # 1454b68c + fix.patch (only if a break is fixed)
unset GOLDEN_DEFER
export FENCED="$(sed -n 's/^FENCED="\([A-Za-z0-9_ ]*\)"$/\1/p' $R204_ROOT/tools/probe/r11u107repro/canaudit.sh | head -1)"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env.sh: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export FENCE_RE="\\b($(echo $FENCED | tr ' ' '|'))\\b"

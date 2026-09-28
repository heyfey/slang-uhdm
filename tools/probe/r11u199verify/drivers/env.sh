# r11u199 environment: pinned tools, frozen binaries, the fence list read from the FENCED= line of
# tools/probe/r11u107repro/canaudit.sh of THIS checkout (resolved from this file's path; never spelled here, never read
# from RESUME.md).  Fail closed: refuses without four names.  (Adapted from r11u194verify/drivers/env.sh.)
R199_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"; export R199_ROOT
export R199_DIR=$R199_ROOT/tools/probe/r11u199verify
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export R199_BIN=${R199_BIN:-/tmp/r11u199_bin}
export STRICT_CMP=${STRICT_CMP:-$R199_BIN/uhdm-strictcmp}
export LAW=${LAW:-$R199_BIN/law.bin}     # 58905f76 (HEAD) = the main tree's build/slang-uhdm (4519cd58f783)
export FIX=${FIX:-$R199_BIN/fix.bin}     # 58905f76 + fix.patch (only if a break is fixed)
unset GOLDEN_DEFER
export FENCED="$(sed -n 's/^FENCED="\([A-Za-z0-9_ ]*\)"$/\1/p' $R199_ROOT/tools/probe/r11u107repro/canaudit.sh | head -1)"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env.sh: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export FENCE_RE="\\b($(echo $FENCED | tr ' ' '|'))\\b"

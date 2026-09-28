# r11u194 environment: pinned tools, frozen binaries, the fence list read from the FENCED= line of
# tools/probe/r11u107repro/canaudit.sh of THIS checkout (resolved from this file's path; never spelled here, never read
# from RESUME.md).  Fail closed: refuses without four names.
R194_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"; export R194_ROOT
export R194_DIR=$R194_ROOT/tools/probe/r11u194verify
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export R194_BIN=${R194_BIN:-/tmp/r11u194_bin}
export STRICT_CMP=${STRICT_CMP:-$R194_BIN/uhdm-strictcmp}
export LAW=${LAW:-$R194_BIN/law.bin}     # 706ab521 (HEAD) = the main tree's build/slang-uhdm
export FIX=${FIX:-$R194_BIN/fix.bin}     # 706ab521 + fix.patch (only if a break is fixed)
unset GOLDEN_DEFER
export FENCED="$(sed -n 's/^FENCED="\([A-Za-z0-9_ ]*\)"$/\1/p' $R194_ROOT/tools/probe/r11u107repro/canaudit.sh | head -1)"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env.sh: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export FENCE_RE="\\b($(echo $FENCED | tr ' ' '|'))\\b"

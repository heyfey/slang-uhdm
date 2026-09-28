# r11u217 environment (adapted from r11u213verify/drivers/env.sh): pinned tools, frozen binaries, the fence list read
# from the FENCED= line of tools/probe/r11u107repro/canaudit.sh of THIS checkout (resolved from this file's path; never
# spelled here, never read from RESUME.md).  Fail closed: refuses without four names.
R217_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"; export R217_ROOT
export R217_DIR=$R217_ROOT/tools/probe/r11u217verify
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export R217_BIN=${R217_BIN:-/tmp/r11u217_bin}
export STRICT_CMP=${STRICT_CMP:-$R217_BIN/uhdm-strictcmp}
export LAW=${LAW:-$R217_BIN/law.bin}     # 83ee16d6 (passes 209, 210, 212 landed, r11u213's refinement) = the main tree build/slang-uhdm (8c724b640425)
export FIX=${FIX:-$R217_BIN/fix.bin}     # 83ee16d6 + fix.patch (only if a break is fixed)
unset GOLDEN_DEFER
export FENCED="$(sed -n 's/^FENCED="\([A-Za-z0-9_ ]*\)"$/\1/p' $R217_ROOT/tools/probe/r11u107repro/canaudit.sh | head -1)"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env.sh: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export FENCE_RE="\\b($(echo $FENCED | tr ' ' '|'))\\b"

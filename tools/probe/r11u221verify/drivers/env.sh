# r11u221 environment (adapted from r11u217verify/drivers/env.sh): pinned tools, frozen binaries, the fence list read
# from the FENCED= line of tools/probe/r11u107repro/canaudit.sh of THIS checkout (resolved from this file's path; never
# spelled here, never read from RESUME.md).  Fail closed: refuses without four names.
R221_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"; export R221_ROOT
export R221_DIR=$R221_ROOT/tools/probe/r11u221verify
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export R221_BIN=${R221_BIN:-/tmp/r11u221_bin}
export STRICT_CMP=${STRICT_CMP:-$R221_BIN/uhdm-strictcmp}
export LAW=${LAW:-$R221_BIN/law.bin}     # 57ce3ae8 (passes 216 and 215 landed) = the main tree build/slang-uhdm (de9af7b93a57)
export FIX=${FIX:-$R221_BIN/fix2.bin}    # 57ce3ae8 + fix.patch (both refinements; fix.bin = the twin-order refinement alone, a development step)
unset GOLDEN_DEFER
export FENCED="$(sed -n 's/^FENCED="\([A-Za-z0-9_ ]*\)"$/\1/p' $R221_ROOT/tools/probe/r11u107repro/canaudit.sh | head -1)"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env.sh: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export FENCE_RE="\\b($(echo $FENCED | tr ' ' '|'))\\b"

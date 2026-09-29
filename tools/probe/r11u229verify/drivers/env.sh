# r11u229 environment (adapted from r11u226verify/drivers/env.sh): pinned tools, frozen binaries, the fence list read
# from the FENCED= line of tools/probe/r11u107repro/canaudit.sh of THIS checkout (resolved from this file's path; never
# spelled here).  Fail closed: refuses without four names, and refuses when any tool variable is not an executable
# file (an unset tool variable made the shell execute a .uhdm database as a script: passes 223, 224, 225 and map 14).
R229_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"; export R229_ROOT
export R229_DIR=$R229_ROOT/tools/probe/r11u229verify
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export R229_BIN=${R229_BIN:-/tmp/r11u229_bin}
export STRICT_CMP=${STRICT_CMP:-$R229_BIN/uhdm-strictcmp}
export LAW=${LAW:-$R229_BIN/law.bin}     # 01dc93ab = the main tree build/slang-uhdm (22bb3dc75f6a): passes 224, 225 and r11u226's fixes landed
export FIX=${FIX:-$R229_BIN/fix.bin}     # 01dc93ab + fix.patch (only if a break is proven)
export GW=${GW:-/tmp/r11u229_g}
unset GOLDEN_DEFER
for _v in SURELOG UHDM_CMP UHDM_DUMP STRICT_CMP LAW; do
  [ -x "${!_v}" ] || { echo "env.sh: $_v='${!_v}' is not an executable file" >&2; return 1 2>/dev/null || exit 1; }
done
export FENCED="$(sed -n 's/^FENCED="\([A-Za-z0-9_ ]*\)"$/\1/p' $R229_ROOT/tools/probe/r11u107repro/canaudit.sh | head -1)"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env.sh: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export FENCE_RE="\\b($(echo $FENCED | tr ' ' '|'))\\b"

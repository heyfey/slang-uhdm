# r11u233 environment (adapted from r11u229verify/drivers/env.sh): pinned tools, frozen binaries, the fence list read
# from the FENCED= line of tools/probe/r11u107repro/canaudit.sh of THIS checkout (resolved from this file's path; never
# spelled here).  Fail closed: refuses without four names, and refuses when any tool variable is not an executable
# file (an unset tool variable made the shell execute a .uhdm database as a script: passes 223, 224, 225, 228v and map 14).
R233_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"; export R233_ROOT
export R233_DIR=$R233_ROOT/tools/probe/r11u233verify
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export R233_BIN=${R233_BIN:-/tmp/r11u233_bin}
export STRICT_CMP=${STRICT_CMP:-$R233_BIN/uhdm-strictcmp}
export LAW=${LAW:-$R233_BIN/law.bin}     # aba8c391 = the main tree build/slang-uhdm (8d6b76685739): passes 227 and 228 landed
export FIX=${FIX:-$R233_BIN/fix.bin}     # aba8c391 + /tmp/r11u233_fix.patch (only if a break is proven)
export GW=${GW:-/tmp/r11u233_g}
unset GOLDEN_DEFER
for _v in SURELOG UHDM_CMP UHDM_DUMP STRICT_CMP LAW; do
  [ -x "${!_v}" ] || { echo "env.sh: $_v='${!_v}' is not an executable file" >&2; return 1 2>/dev/null || exit 1; }
done
export FENCED="$(sed -n 's/^FENCED="\([A-Za-z0-9_ ]*\)"$/\1/p' $R233_ROOT/tools/probe/r11u107repro/canaudit.sh | head -1)"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env.sh: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export FENCE_RE="\\b($(echo $FENCED | tr ' ' '|'))\\b"

# v11u228 (copied from r11u228repro/drivers): the pins, the frozen binaries and the fence. Source it: `. drivers/env.sh`.
# Paths resolve from the repository that holds this file (never from a scratch worktree by name).
_H228="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO="$(cd "$_H228/../../../.." && pwd)"
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
# $B: the directory of the frozen binaries (pristine, law...), exported by the caller.
export B=${B:-/tmp/v11u228_bin}
export STRICT_CMP=${STRICT_CMP:-$B/uhdm-strictcmp}
# The four slang-fenced names come from the FENCED= line of tools/probe/r11u107repro/canaudit.sh (never spelled
# here, never read from RESUME.md by line number). Fail closed.
export FENCED="$(grep -m1 '^FENCED=' $REPO/tools/probe/r11u107repro/canaudit.sh | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export FENCE_RE="\\b($(echo $FENCED | tr ' ' '|'))\\b"
# Guard (pass 223's finding): never call a tool through an unset variable.
for _v228 in SURELOG UHDM_CMP UHDM_DUMP STRICT_CMP; do [ -x "${!_v228}" ] || { echo "env: $_v228 not executable" >&2; return 1 2>/dev/null || exit 1; }; done

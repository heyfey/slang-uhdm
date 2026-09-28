# v11u212 (from r11u212repro/drivers): the pins, the frozen binaries (B, default /tmp/v11u212_bin: pristine.bin law.bin fix1.bin strictcmp) and the fence. Source it.
# Paths resolve from the repository that holds this file (never from a scratch worktree by name).
_H212V="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO="$(cd "$_H212V/../../../.." && pwd)"
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export B=${B:-/tmp/v11u212_bin}
export SLANG_UHDM=${SLANG_UHDM:-$B/pristine.bin} STRICT_CMP=${STRICT_CMP:-/tmp/v11u212_bin/strictcmp}
# The four slang-fenced names come from the FENCED= line of tools/probe/r11u107repro/canaudit.sh (never spelled here,
# never read from RESUME.md by line number). Fail closed.
export FENCED="$(grep -m1 '^FENCED=' $REPO/tools/probe/r11u107repro/canaudit.sh | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export FENCE_RE="$(echo $FENCED | tr ' ' '|')"

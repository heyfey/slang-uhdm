# v11u201: pins + fence (fail closed). Source it. The fence is the FENCED= line of tools/probe/r11u107repro/canaudit.sh
# in the MAIN repository (resolved through git's common dir, never from a scratch worktree).
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export VB=${VB:-/tmp/v11u201_bin}; export STRICT_CMP=${STRICT_CMP:-$VB/uhdm-strictcmp} SCMP=${SCMP:-$VB/uhdm-strictcmp}
export V201DRV=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export REPO="$(cd "$(git -C "$V201DRV" rev-parse --path-format=absolute --git-common-dir)/.." && pwd)"
export FENCED="$(grep -m1 '^FENCED=' "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }

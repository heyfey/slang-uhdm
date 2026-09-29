# v11u215: pins + fence. Source it. REPO = the main repository (resolved through git's common dir of this directory, so a
# scratch worktree never supplies the fence); fail closed on the fence (the FENCED= line of r11u107repro/canaudit.sh).
_v215here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export REPO="$(cd "$(git -C "$_v215here" rev-parse --path-format=absolute --git-common-dir)/.." && pwd)"
export SURELOG_ROOT=$REPO/third_party/Surelog UHDM2RTLIL_TESTS=$REPO/third_party/uhdm2rtlil/test UHDM2RTLIL_ROOT=$REPO/third_party/uhdm2rtlil
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export V215=$_v215here B=${B:-/tmp/v11u215_bin} SCMP=${SCMP:-/tmp/v11u215_bin/uhdm-strictcmp}
# the worktree whose scripts/ and tests/ the drivers run (default: the main repository)
export WT=${WT:-$REPO}
export FENCED="$(grep -m1 '^FENCED=' "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }

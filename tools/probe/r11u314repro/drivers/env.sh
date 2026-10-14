# (r11u314: copied from r11u312repro/drivers, renamed to R11U314 / r11u314)
# (r11u314: copied from r11u310repro/drivers, renamed to R11U314 / r11u314)
# (r11u310: copied from r11u308repro/drivers, renamed to R11U310 / r11u310)
# (r11u308: copied from r11u306repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u304repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u302repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u300repro/drivers, renamed to R11U308 / r11u308)
# (r11u308: copied from r11u298repro/drivers)
# (r11u298: copied from v11u294repro/drivers)
# (r11u294: copied from r11u292repro/drivers)
# (r11u292: copied from r11u288repro/drivers)
# (r11u286: copied from r11u284repro; r11u282: copied from v11u202repro/drivers; VB defaults to /tmp/r11u314_bin)
# v11u202: pins + fence (source it). Paths resolve from the repo that holds this file; the fence is read
# fail-closed from the FENCED= line of tools/probe/r11u107repro/canaudit.sh.  VB = the frozen binaries' dir.
_v202here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd); export V202_REPO=$(cd "$_v202here/../../../.." && pwd)
# a worktree has EMPTY submodule dirs: the corpora resolve from the checkout that owns the git dir
_v202tp=$V202_REPO; [ -d "$_v202tp/third_party/Surelog/tests" ] || _v202tp=$(cd "$(git -C "$V202_REPO" rev-parse --git-common-dir)/.." && pwd)
export SURELOG_ROOT=$_v202tp/third_party/Surelog UHDM2RTLIL_TESTS=$_v202tp/third_party/uhdm2rtlil/test UHDM2RTLIL_ROOT=$_v202tp/third_party/uhdm2rtlil
: "${SURELOG:=/home/heyfey/git-repos/Surelog/build/bin/surelog}" "${UHDM_CMP:=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp}" "${UHDM_DUMP:=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump}"
export SURELOG UHDM_CMP UHDM_DUMP
export VB=${VB:-/tmp/r11u314_bin}; export STRICT_CMP=${STRICT_CMP:-$VB/uhdm-strictcmp} SCMP=${SCMP:-$VB/uhdm-strictcmp}
export FENCED="$(grep -m1 '^FENCED=' "$V202_REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export FENCERE="\\b($(echo $FENCED | tr ' ' '|'))\\b"

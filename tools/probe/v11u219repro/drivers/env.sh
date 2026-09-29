# v11u219 (adversarial verification of r11u219): pins, frozen binaries, fence. Source it.
# Paths resolve from the repository holding this file; the fence is read fail-closed from
# tools/probe/r11u107repro/canaudit.sh's FENCED= line (never spelled here).
_HV219="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO="$(cd "$_HV219/../../../.." && pwd)"
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export VB=${VB:-/tmp/v11u219_bin}
export STRICT_CMP=${STRICT_CMP:-$VB/uhdm-strictcmp}
export S=${S:-/tmp/v11u219_g}
export FENCED="$(grep -m1 '^FENCED=' $REPO/tools/probe/r11u107repro/canaudit.sh | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export FENCE_RE="\\b($(echo $FENCED | tr ' ' '|'))\\b"
unset GOLDEN_DEFER

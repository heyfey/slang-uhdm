# r11u191: pins + fence. Source it. Fail closed on the fence (the FENCED= line of r11u107repro/canaudit.sh).
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export B=/tmp/r11u191_bin WT=/tmp/wt_r11u191 STRICT_CMP=/tmp/r11u191_bin/uhdm-strictcmp SCMP=/tmp/r11u191_bin/uhdm-strictcmp
_r191here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export FENCED="$(grep -m1 '^FENCED=' "$_r191here/../../r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }

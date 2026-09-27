# v11u181 environment: the pins and the fence (FENCED read from canaudit.sh, fail closed); scratch under /tmp/v11u181_*
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export STRICT_CMP=/tmp/v11u181_bin/uhdm-strictcmp
R181V=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)
eval "$(grep -m1 "^FENCED=" $R181V/tools/probe/r11u107repro/canaudit.sh)"
[ $(echo $FENCED | wc -w) -eq 4 ] || { echo "FENCE: need 4 names" >&2; exit 9; }
export FENCED
export FENCED_RE="\\b($(echo $FENCED | tr ' ' '|'))\\b"

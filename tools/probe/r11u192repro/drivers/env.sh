# r11u192 environment: pins and the fence (names read from canaudit.sh's FENCED= line, never spelled here)
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export STRICT_CMP=/tmp/r11u192_bin/uhdm-strictcmp
export STRICT=$STRICT_CMP
# (the repository root is resolved from this file)
R192=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)
FENCED=$(sed -n 's/^FENCED="\(.*\)"$/\1/p' $R192/tools/probe/r11u107repro/canaudit.sh)
export FENCED
_nf=$(echo $FENCED | wc -w)
if [ "$_nf" -ne 4 ]; then echo "env.sh: FENCED must hold four names" >&2; return 1 2>/dev/null || exit 1; fi
FENCED_RE="\\b($(echo $FENCED | tr ' ' '|'))\\b"
export FENCED_RE
: "${SLANG_UHDM:?export SLANG_UHDM=<frozen binary>}"

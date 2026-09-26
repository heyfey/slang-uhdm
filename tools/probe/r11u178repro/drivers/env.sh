# r11u178 environment: pins and the fence (names read from canaudit.sh's FENCED= line, never spelled here)
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export STRICT=/tmp/r11u178_bin/uhdm-strictcmp
FENCED=$(sed -n 's/^FENCED="\(.*\)"$/\1/p' /tmp/wt_r11u178/tools/probe/r11u107repro/canaudit.sh)
export FENCED
set -- $FENCED
if [ $# -ne 4 ]; then echo "env.sh: FENCED must hold four names" >&2; return 1 2>/dev/null || exit 1; fi
FENCED_RE="\\b($(echo $FENCED | tr ' ' '|'))\\b"
export FENCED_RE
: "${SLANG_UHDM:?export SLANG_UHDM=<frozen binary>}"

export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
FENCED=$(sed -n 's/^FENCED="\(.*\)"$/\1/p' /tmp/wt_v11u178/tools/probe/r11u107repro/canaudit.sh)
export FENCED
set -- $FENCED
if [ $# -ne 4 ]; then echo "env: FENCED must hold four names" >&2; return 1 2>/dev/null || exit 1; fi
export FENCED_RE="\\b($(echo $FENCED | tr ' ' '|'))\\b"
export PRIS=/tmp/v11u178_bin/pris.bin LAW=/tmp/v11u178_bin/law.bin STRICT=/tmp/v11u178_bin/uhdm-strictcmp
export STRICT_CMP=/tmp/v11u178_bin/uhdm-strictcmp

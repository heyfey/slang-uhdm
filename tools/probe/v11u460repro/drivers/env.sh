export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export STRICTCMP=/tmp/wt_v11u460/build/uhdm-strictcmp
export PRIS=/tmp/v11u460_bin/pristine LAW=/tmp/v11u460_bin/law VER=/tmp/v11u460_bin/ver
for v in SURELOG UHDM_CMP UHDM_DUMP STRICTCMP PRIS LAW VER; do eval "[ -x \"\$$v\" ]" || { echo "missing $v"; return 1 2>/dev/null || exit 1; }; done

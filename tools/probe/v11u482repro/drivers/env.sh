export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export STRICTCMP=/tmp/v11u482_bin/strictcmp OBJCENSUS=/tmp/v11u482_bin/objcensus TSINST=/tmp/v11u482_bin/tsinst
export MSDIST=/tmp/wt_v11u482/tools/probe/r11u482repro/evidence/tools/msdist.py
for v in SURELOG UHDM_CMP UHDM_DUMP STRICTCMP OBJCENSUS TSINST; do eval "p=\$$v"; [ -x "$p" ] || { echo "MISSING $v"; return 1; }; done

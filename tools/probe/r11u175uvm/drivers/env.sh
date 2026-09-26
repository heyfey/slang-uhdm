export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export B=/tmp/r11u175_bin WT=/tmp/wt_r11u175 S=/tmp/r11u175_scratch
export SLANG_UHDM=${SLANG_UHDM:-/tmp/r11u175_bin/slang-uhdm}
export STRICT_CMP=/tmp/r11u175_bin/uhdm-strictcmp
export GCACHE=${GCACHE:-/tmp/r11u175_gold} OUT=${OUT:-/tmp/r11u175_scratch/caseout}
export FENCED="$(grep -o 'for n in [A-Za-z ]*;' /home/heyfey/git-repos/slang-uhdm/RESUME.md | head -1 | sed 's/for n in //; s/;//')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }

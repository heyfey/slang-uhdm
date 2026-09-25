# r11u149verify environment (pinned tools; the binary under test is SLANG_UHDM)
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export STRICT_CMP=/tmp/r11u149_bin/uhdm-strictcmp
unset GOLDEN_DEFER
# the four slang-fenced test names, read from RESUME.md's own fence-check loop (never spelled in this directory)
export FENCED=$(grep -o 'for n in [A-Za-z ]*; do' /tmp/wt_r11u149/RESUME.md | head -1 | sed 's/for n in //; s/; do//')

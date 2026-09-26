# r11u173 environment: pinned tools, frozen binaries, the fence list (built from RESUME.md, never spelled).
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export STRICT_CMP=/tmp/r11u173_bin/uhdm-strictcmp
export LAW=/tmp/r11u173_bin/law.bin     # edb34d8a (HEAD) = the main tree's build/slang-uhdm
export PRE=/tmp/r11u173_bin/pre.bin     # d8cfd83a, the commit before pass 164
export FIX=${FIX:-/tmp/r11u173_bin/fix.bin}
unset GOLDEN_DEFER
export FENCED="$(grep -o 'for n in [A-Za-z ]*;' /home/heyfey/git-repos/slang-uhdm/RESUME.md | head -1 | sed 's/for n in //; s/;//')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env.sh: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export FENCE_RE="\\b($(echo $FENCED | tr ' ' '|'))\\b"

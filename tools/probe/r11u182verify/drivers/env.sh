# r11u182 environment: pinned tools, frozen binaries, the fence list read from the FENCED= line of
# tools/probe/r11u107repro/canaudit.sh (never spelled here, never read from RESUME.md by line number).  Fail closed.
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export STRICT_CMP=/tmp/r11u182_bin/uhdm-strictcmp
export LAW=${LAW:-/tmp/r11u182_bin/law.bin}     # 7fadac8a (HEAD) = the main tree's build/slang-uhdm
export PRE=${PRE-/tmp/r11u182_bin/pre.bin}      # 50a01bc3, the commit before pass 171
export FIX=${FIX:-/tmp/r11u182_bin/fix.bin}     # 7fadac8a + fix.patch (only if a break is fixed)
unset GOLDEN_DEFER
export FENCED="$(sed -n 's/^FENCED="\([A-Za-z0-9_ ]*\)"$/\1/p' /tmp/wt_r11u182/tools/probe/r11u107repro/canaudit.sh | head -1)"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env.sh: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export FENCE_RE="\\b($(echo $FENCED | tr ' ' '|'))\\b"

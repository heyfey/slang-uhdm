# r11u183: pins + fence. Source it. Fail closed on the fence (the FENCED= line of r11u107repro/canaudit.sh).
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export B=/tmp/r11u183_bin WT=/tmp/wt_r11u183 STRICT_CMP=/tmp/r11u183_bin/uhdm-strictcmp SCMP=/tmp/r11u183_bin/uhdm-strictcmp
export FENCED="$(grep -m1 '^FENCED=' /tmp/wt_r11u183/tools/probe/r11u107repro/canaudit.sh | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }

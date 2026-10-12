# v11u288 env.sh: the pinned tool paths and $FENCED / $FENCERE read fail-closed from tools/probe/r11u107repro/canaudit.sh
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog
export UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test
export SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
export UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp
export UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
export UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
FENCED=$(grep -m1 '^FENCED=' $(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/r11u107repro/canaudit.sh | sed 's/^FENCED=//; s/^"//; s/"$//')
[ -n "$FENCED" ] || { echo "FENCED unreadable" >&2; return 1 2>/dev/null || exit 1; }
export FENCED
export FENCERE="$(echo $FENCED | tr ' ' '|')"
for v in SURELOG UHDM_CMP UHDM_DUMP; do eval "x=\$$v"; [ -x "$x" ] || { echo "$v not executable" >&2; return 1 2>/dev/null || exit 1; }; done

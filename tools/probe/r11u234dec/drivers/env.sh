# r11u234dec env: the pins, the frozen binaries and the fence. Source it: `. drivers/env.sh`.
# Scratch locations are NOT hard-coded: export DEC_W (work dir) and DEC_BIN (frozen binaries dir) before sourcing;
# REPO is this checkout, resolved from this file's own location; MAP is map 15's driver dir (analyze.py, common.py).
_DR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export DR=$_DR REPO=$(cd "$_DR/../../../.." && pwd)
export MAP=$REPO/tools/probe/r11u230map/drivers
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
: "${DEC_W:?export DEC_W (the scratch work dir)}" "${DEC_BIN:?export DEC_BIN (the frozen binaries dir)}"
export STRICT_CMP=$DEC_BIN/uhdm-strictcmp STRICTX=$DEC_BIN/strictcmp_x
export FENCED="$(grep -m1 '^FENCED=' "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
for _v in STRICT_CMP STRICTX UHDM_CMP UHDM_DUMP; do [ -x "${!_v}" ] || { echo "env: $_v not executable" >&2; return 1 2>/dev/null || exit 1; }; done

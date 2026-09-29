# r11u230map (fifteenth edition; map 14's env.sh): the pins, the frozen binaries and the fence. Source it: `. drivers/env.sh`.
# Scratch locations are NOT hard-coded: export MAP_W (work dir), MAP_BIN (frozen binaries), MAP_H (the HEAD sweep to
# read) before sourcing; REPO is this checkout, resolved from this file's own location.
_DR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export DR=$_DR REPO=$(cd "$_DR/../../../.." && pwd)
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
: "${MAP_W:?export MAP_W (the map scratch work dir)}" "${MAP_BIN:?export MAP_BIN (the frozen binaries dir)}" "${MAP_H:?export MAP_H (the HEAD sweep dir, read-only)}"
export W=$MAP_W B=$MAP_BIN H=$MAP_H
export SLANG_UHDM=${SLANG_UHDM:-$B/slang-uhdm} STRICT_CMP=$B/uhdm-strictcmp
# The four slang-fenced names come from the FENCED= line of tools/probe/r11u107repro/canaudit.sh (never spelled here,
# never read from RESUME.md by line number). Fail closed.
export FENCED="$(grep -m1 '^FENCED=' "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export FENCERE="\\b($(echo $FENCED | tr " " "|"))\\b"

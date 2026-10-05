# v11u255 (adversarial verification of r11u255): pins, binaries and fence. Source it: `. drivers/env.sh`.
# Paths resolve from this checkout; $B (frozen binaries: pristine, law, uhdm-strictcmp) and $S (scratch root) are
# exported by the caller. The fence names come from the FENCED= line of tools/probe/r11u107repro/canaudit.sh
# (never spelled here); fail closed. The r11u255repro drivers this pass reuses read the same variables.
V255_HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export REPO=$(cd "$V255_HERE/../../../.." && pwd)
export R255D=$REPO/tools/probe/r11u255repro/drivers
[ -n "$B" ] && [ -d "$B" ] || { echo "env: export B" >&2; return 1 2>/dev/null || exit 1; }
[ -n "$S" ] || { echo "env: export S" >&2; return 1 2>/dev/null || exit 1; }
. "$R255D/env.sh" || { return 1 2>/dev/null || exit 1; }

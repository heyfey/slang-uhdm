# (r11u263: copied from r11u261repro/drivers)
# (r11u269: copied from r11u267repro/drivers)
# (r11u267: copied from r11u265repro/drivers)
# (r11u265: copied from r11u263repro/drivers)
# (r11u261: copied from r11u259repro/drivers)
# (r11u259: copied from r11u257repro/drivers)
# (r11u255: copied from r11u253repro/drivers)
# (r11u257: copied from r11u255repro/drivers)
# (r11u253: copied from r11u251repro/drivers)
# (r11u251: copied from r11u249repro/drivers)
# (r11u249: copied from r11u247repro/drivers)
# (r11u244: copied from r11u242repro/drivers)
# (r11u247: copied from r11u244repro/drivers)
# (r11u242: copied from r11u240repro/drivers)
# (r11u238: copied from r11u236repro/drivers)
# (r11u240: copied from r11u238repro/drivers)
# (r11u236: copied from r11u232repro/drivers)
# (r11u232: copied from r11u227repro/drivers)
# (r11u224: copied from r11u220repro/drivers)
# r11u236repro: the pins, the binaries and the fence. Source it: `. drivers/env.sh`.
# Paths resolve from this checkout; the binaries' directory ($B) and the scratch root ($S) must be exported by the
# caller (no scratch path is written here). The fence names come from the FENCED= line of
# tools/probe/r11u107repro/canaudit.sh (never spelled here); fail closed.
R249_HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export REPO=$(cd "$R249_HERE/../../../.." && pwd)
MAIN=$(cd "$REPO" && git rev-parse --path-format=absolute --git-common-dir 2>/dev/null | sed 's#/\.git$##')
[ -d "$MAIN/third_party/Surelog/src" ] || MAIN=$REPO
export SURELOG_ROOT=${SURELOG_ROOT:-$MAIN/third_party/Surelog} UHDM2RTLIL_TESTS=${UHDM2RTLIL_TESTS:-$MAIN/third_party/uhdm2rtlil/test}
export UHDM2RTLIL_ROOT=${UHDM2RTLIL_ROOT:-$MAIN/third_party/uhdm2rtlil}
export SURELOG=${SURELOG:?export SURELOG} UHDM_CMP=${UHDM_CMP:?export UHDM_CMP} UHDM_DUMP=${UHDM_DUMP:?export UHDM_DUMP}
[ -n "$B" ] && [ -d "$B" ] || { echo "env: export B (the frozen binaries' directory)" >&2; return 1 2>/dev/null || exit 1; }
[ -n "$S" ] || { echo "env: export S (the scratch root)" >&2; return 1 2>/dev/null || exit 1; }
export B S STRICT_CMP=${STRICT_CMP:-$B/uhdm-strictcmp}
export FENCED="$(grep -m1 '^FENCED=' "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export FENCE_RE="$(echo $FENCED | tr ' ' '|')"
for t in SURELOG UHDM_CMP UHDM_DUMP STRICT_CMP; do eval "p=\$$t"; [ -x "$p" ] || { echo "env: $t not executable" >&2; return 1 2>/dev/null || exit 1; }; done

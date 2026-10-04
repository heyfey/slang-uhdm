# v11u232repro: the pins, the frozen binaries and the fence. Source it: `. drivers/env.sh`.
# The caller exports B (the frozen binaries' directory: pristine, law, fix, uhdm-strictcmp, strictcmp_x) and
# S (the scratch root); SURELOG, UHDM_CMP, UHDM_DUMP as the brief pins them. The fence names come from the FENCED=
# line of tools/probe/r11u107repro/canaudit.sh (never spelled here); fail closed.
V232_HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export REPO=$(cd "$V232_HERE/../../../.." && pwd)
export SURELOG=${SURELOG:?export SURELOG} UHDM_CMP=${UHDM_CMP:?export UHDM_CMP} UHDM_DUMP=${UHDM_DUMP:?export UHDM_DUMP}
[ -n "$B" ] && [ -d "$B" ] || { echo "env: export B" >&2; return 1 2>/dev/null || exit 1; }
[ -n "$S" ] || { echo "env: export S" >&2; return 1 2>/dev/null || exit 1; }
export B S STRICT_CMP=${STRICT_CMP:-$B/uhdm-strictcmp}
export FENCED="$(grep -m1 '^FENCED=' "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export FENCE_RE="$(echo $FENCED | tr ' ' '|')"
for t in SURELOG UHDM_CMP UHDM_DUMP STRICT_CMP; do eval "p=\$$t"; [ -x "$p" ] || { echo "env: $t not executable" >&2; return 1 2>/dev/null || exit 1; }; done

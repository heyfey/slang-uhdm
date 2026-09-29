# v11u220repro: pins, binaries, fence. Source it. Paths resolve from this checkout; the caller exports B (frozen
# binaries' directory) and S (scratch root). FENCED comes from the FENCED= line of tools/probe/r11u107repro/canaudit.sh
# (never spelled here); fail closed.
V220_HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
export REPO=$(cd "$V220_HERE/../../../.." && pwd)
MAIN=$(cd "$REPO" && git rev-parse --path-format=absolute --git-common-dir 2>/dev/null | sed 's#/\.git$##')
[ -d "$MAIN/third_party/Surelog/src" ] || MAIN=$REPO
export SURELOG_ROOT=${SURELOG_ROOT:-$MAIN/third_party/Surelog} UHDM2RTLIL_TESTS=${UHDM2RTLIL_TESTS:-$MAIN/third_party/uhdm2rtlil/test}
export UHDM2RTLIL_ROOT=${UHDM2RTLIL_ROOT:-$MAIN/third_party/uhdm2rtlil}
export SURELOG=${SURELOG:?export SURELOG} UHDM_CMP=${UHDM_CMP:?export UHDM_CMP} UHDM_DUMP=${UHDM_DUMP:?export UHDM_DUMP}
[ -n "$B" ] && [ -d "$B" ] || { echo "env: export B" >&2; return 1 2>/dev/null || exit 1; }
[ -n "$S" ] || { echo "env: export S" >&2; return 1 2>/dev/null || exit 1; }
export B S STRICT_CMP=${STRICT_CMP:-$B/uhdm-strictcmp}
export FENCED="$(grep -m1 '^FENCED=' "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export FENCE_RE="$(echo $FENCED | tr ' ' '|')"

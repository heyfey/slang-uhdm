# v11u187 environment: pins and the fence (the four names read from canaudit.sh's FENCED= line, never spelled here).
# Export PRIS and LAW (the frozen pristine and law binaries) before sourcing.
V187=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)
export SURELOG_ROOT=$V187/third_party/Surelog UHDM2RTLIL_TESTS=$V187/third_party/uhdm2rtlil/test UHDM2RTLIL_ROOT=$V187/third_party/uhdm2rtlil
export SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
export UHDM_CMP=${UHDM_CMP:-$HOME/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp}
export UHDM_DUMP=${UHDM_DUMP:-$HOME/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump}
export STRICT=${STRICT_CMP:-$V187/build/uhdm-strictcmp}
FENCED=$(sed -n 's/^FENCED="\(.*\)"$/\1/p' $V187/tools/probe/r11u107repro/canaudit.sh); export FENCED
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env.sh: FENCED must hold four names: refusing" >&2; return 1 2>/dev/null || exit 1; }
export FENCERE="\\b($(echo $FENCED | tr ' ' '|'))\\b"
: "${PRIS:?export PRIS=<frozen pristine binary>}" "${LAW:?export LAW=<frozen law binary>}"

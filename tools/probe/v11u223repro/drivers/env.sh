# v11u223: the pins, the frozen binaries and the fence. Source it: `. drivers/env.sh`.
# Paths resolve from the repository that holds this file. $B names the directory of the frozen binaries
# (pristine, law, fix2, uhdm-strictcmp); the caller exports it (the default is this pass's scratch).
_H="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO="$(cd "$_H/../../../.." && pwd)"
export SURELOG_ROOT=$REPO/third_party/Surelog UHDM2RTLIL_TESTS=$REPO/third_party/uhdm2rtlil/test UHDM2RTLIL_ROOT=$REPO/third_party/uhdm2rtlil
export SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
export UHDM_CMP=${UHDM_CMP:-$HOME/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp}
export UHDM_DUMP=${UHDM_DUMP:-$HOME/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump}
# Never call a tool through an unset or missing path: a .uhdm run as a shell script writes stray files.
for v in SURELOG UHDM_CMP UHDM_DUMP; do [ -x "${!v}" ] || { echo "env: $v missing" >&2; return 1 2>/dev/null || exit 1; }; done
export B=${B:-/tmp/v11u223_bin}
export STRICT_CMP=${STRICT_CMP:-$B/uhdm-strictcmp}
# The four slang-fenced names come from the FENCED= line of tools/probe/r11u107repro/canaudit.sh; fail closed.
export FENCED="$(grep -m1 '^FENCED=' $REPO/tools/probe/r11u107repro/canaudit.sh | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }

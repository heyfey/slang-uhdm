# v11u196: the pins and the fence. Source it: `. <repo>/tools/probe/v11u196repro/drivers/env.sh`.
# Paths resolve from the repo holding this file (its main checkout for the submodules); binaries from $V196_BIN
# (default /tmp/v11u196_bin: pris, law, fix, uhdm-strictcmp, frozen chmod 555).
V196_REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd); export V196_REPO
MAIN=$(git -C "$V196_REPO" worktree list --porcelain | awk '/^worktree /{print $2; exit}'); export V196_MAIN=$MAIN
export V196_BIN=${V196_BIN:-/tmp/v11u196_bin}
export SURELOG_ROOT=$MAIN/third_party/Surelog UHDM2RTLIL_TESTS=$MAIN/third_party/uhdm2rtlil/test UHDM2RTLIL_ROOT=$MAIN/third_party/uhdm2rtlil
export SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
export UHDM_CMP=${UHDM_CMP:-$HOME/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp}
export UHDM_DUMP=${UHDM_DUMP:-$HOME/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump}
export STRICT_CMP=${STRICT_CMP:-$V196_BIN/uhdm-strictcmp}
# The four slang-fenced names: the FENCED= line of tools/probe/r11u107repro/canaudit.sh; fail closed.
export FENCED="$(grep -m1 '^FENCED=' "$V196_REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 3 2>/dev/null || exit 3; }

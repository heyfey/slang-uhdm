# r11u193: the pins and the fence. Source it: `. <repo>/tools/probe/r11u193repro/drivers/env.sh`.
# Paths resolve from the repo holding this file; the frozen binaries dir is $R193_BIN (required, set by the caller).
R193_REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd); export R193_REPO
MAIN=$(git -C "$R193_REPO" worktree list --porcelain | awk '/^worktree /{print $2; exit}'); export R193_MAIN=$MAIN
export SURELOG_ROOT=$MAIN/third_party/Surelog UHDM2RTLIL_TESTS=$MAIN/third_party/uhdm2rtlil/test UHDM2RTLIL_ROOT=$MAIN/third_party/uhdm2rtlil
export SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog} UHDM_CMP=${UHDM_CMP:-$HOME/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp} UHDM_DUMP=${UHDM_DUMP:-$HOME/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump}
[ -n "${R193_BIN:-}" ] || { echo "env: set R193_BIN (the frozen binaries dir)" >&2; return 1 2>/dev/null || exit 1; }
export SCMP=${SCMP:-$R193_BIN/uhdm-strictcmp} STRICT_CMP=${STRICT_CMP:-$R193_BIN/uhdm-strictcmp}
# The four slang-fenced names come from the FENCED= line of tools/probe/r11u107repro/canaudit.sh; fail closed.
export FENCED="$(grep -m1 '^FENCED=' "$R193_REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export NEGFENCE="^(?!($(echo $FENCED | tr ' ' '|'))$)"
r193_fenced() { local f; for f in $FENCED; do grep -qw -- "$f" <<< "$1" && return 0; done; return 1; }

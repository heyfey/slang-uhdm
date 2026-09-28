# r11u188: the pins and the fence. Source it: `. <repo>/tools/probe/r11u188repro/drivers/env.sh`.
# Paths resolve from the repo holding this file; the frozen binaries dir is $R188_BIN (required, set by the caller).
R188_REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd); export R188_REPO
MAIN=$(git -C "$R188_REPO" worktree list --porcelain | awk '/^worktree /{print $2; exit}'); export R188_MAIN=$MAIN
export SURELOG_ROOT=$MAIN/third_party/Surelog UHDM2RTLIL_TESTS=$MAIN/third_party/uhdm2rtlil/test UHDM2RTLIL_ROOT=$MAIN/third_party/uhdm2rtlil
export SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog} UHDM_CMP=${UHDM_CMP:-$HOME/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp} UHDM_DUMP=${UHDM_DUMP:-$HOME/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump}
[ -n "${R188_BIN:-}" ] || { echo "env: set R188_BIN (the frozen binaries dir)" >&2; return 1 2>/dev/null || exit 1; }
export SCMP=${SCMP:-$R188_BIN/uhdm-strictcmp} STRICT_CMP=${STRICT_CMP:-$R188_BIN/uhdm-strictcmp}
# The four slang-fenced names come from the FENCED= line of tools/probe/r11u107repro/canaudit.sh; fail closed.
export FENCED="$(grep -m1 '^FENCED=' "$R188_REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export NEGFENCE="^(?!($(echo $FENCED | tr ' ' '|'))$)"
r188_fenced() { local f; for f in $FENCED; do grep -qw -- "$f" <<< "$1" && return 0; done; return 1; }

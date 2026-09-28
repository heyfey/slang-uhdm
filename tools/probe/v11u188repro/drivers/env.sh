# v11u188: the pins and the fence. Source it: `. <repo>/tools/probe/v11u188repro/drivers/env.sh`.
# Paths resolve from the repository holding this file; the frozen binaries directory is $V188_BIN (required:
# pris.bin, law.bin, v2.bin, uhdm-strictcmp).  The four fenced names come from the FENCED= line of
# tools/probe/r11u107repro/canaudit.sh; every driver fails closed without them.
V188_REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd); export V188_REPO
V188_MAIN=$(git -C "$V188_REPO" worktree list --porcelain | awk '/^worktree /{print $2; exit}'); export V188_MAIN
export SURELOG_ROOT=$V188_MAIN/third_party/Surelog UHDM2RTLIL_TESTS=$V188_MAIN/third_party/uhdm2rtlil/test UHDM2RTLIL_ROOT=$V188_MAIN/third_party/uhdm2rtlil
export SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog} UHDM_CMP=${UHDM_CMP:-$HOME/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp} UHDM_DUMP=${UHDM_DUMP:-$HOME/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump}
[ -n "${V188_BIN:-}" ] || { echo "env: set V188_BIN (the frozen binaries dir)" >&2; return 1 2>/dev/null || exit 1; }
export SCMP=${SCMP:-$V188_BIN/uhdm-strictcmp} STRICT_CMP=${STRICT_CMP:-$V188_BIN/uhdm-strictcmp}
export FENCED="$(grep -m1 '^FENCED=' "$V188_REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
export NEGFENCE="^(?!($(echo $FENCED | tr ' ' '|'))$)"
v188_fenced() { local f; for f in $FENCED; do grep -qw -- "$f" <<< "$1" && return 0; done; return 1; }

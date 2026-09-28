# v11u193 (adversarial verification of r11u193): pins + fence. Source it. Paths resolve from the repo holding this file;
# $V193_BIN (required) is the frozen-binaries dir: pris.bin, law.bin (r11u193.patch), ref.bin (+ this pass's refinements),
# uhdm-strictcmp, predict (drivers/predict.cpp built against ~/.local UHDM).
REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd); export REPO
MAIN=$(git -C "$REPO" worktree list --porcelain | awk '/^worktree /{print $2; exit}')
export SURELOG_ROOT=$MAIN/third_party/Surelog UHDM2RTLIL_TESTS=$MAIN/third_party/uhdm2rtlil/test UHDM2RTLIL_ROOT=$MAIN/third_party/uhdm2rtlil
export SURELOG=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog} UHDM_CMP=${UHDM_CMP:-$HOME/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp} UHDM_DUMP=${UHDM_DUMP:-$HOME/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump}
[ -n "${V193_BIN:-}" ] || { echo "env: set V193_BIN (the frozen binaries dir)" >&2; return 1 2>/dev/null || exit 1; }
export SCMP=$V193_BIN/uhdm-strictcmp STRICT_CMP=$V193_BIN/uhdm-strictcmp
export V193_GOLD=${V193_GOLD:-/tmp/v11u193_gold} V193_RUN=${V193_RUN:-/tmp/v11u193_run}
# The four slang-fenced names come from the FENCED= line of tools/probe/r11u107repro/canaudit.sh; fail closed.
export FENCED="$(grep -m1 '^FENCED=' "$REPO/tools/probe/r11u107repro/canaudit.sh" | sed 's/^FENCED=//; s/["'"'"']//g')"
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "env: FENCED not 4 names" >&2; return 1 2>/dev/null || exit 1; }
v193_fenced() { local f; for f in $FENCED; do grep -qw -- "$f" <<< "$1" && return 0; done; return 1; }

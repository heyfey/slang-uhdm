#!/bin/bash
# v11u224: one gate sweep. gsweep.sh <worktree> <binary> <workdir> <corpora...>
# The pins resolve from this checkout's main tree (SURELOG_ROOT, UHDM2RTLIL_TESTS, UHDM2RTLIL_ROOT); SURELOG, UHDM_CMP,
# UHDM_DUMP must be exported by the caller. Runs tests/sweep.sh --jobs 3 from <worktree> with SLANG_UHDM=<binary>
# (GOLDEN_DEFER unset); the log is <workdir>.log with the binary's md5 on its first line.
HERE=$(cd "$(dirname "$0")" && pwd); REPO=$(cd "$HERE/../../../.." && pwd)
MAIN=$(cd "$REPO" && git rev-parse --path-format=absolute --git-common-dir 2>/dev/null | sed 's#/\.git$##'); [ -d "$MAIN/third_party/Surelog/src" ] || MAIN=$REPO
wt=$1; bin=$2; wd=$3; shift 3
export SURELOG_ROOT=$MAIN/third_party/Surelog UHDM2RTLIL_TESTS=$MAIN/third_party/uhdm2rtlil/test UHDM2RTLIL_ROOT=$MAIN/third_party/uhdm2rtlil
export SURELOG=${SURELOG:?export SURELOG} UHDM_CMP=${UHDM_CMP:?export UHDM_CMP} UHDM_DUMP=${UHDM_DUMP:?export UHDM_DUMP}
export SLANG_UHDM=$bin
unset GOLDEN_DEFER
[ -x "$bin" ] || { echo "no binary $bin" >&2; exit 2; }
cd "$wt" || exit 2
mkdir -p "$wd"
echo "START $(date -u +%FT%TZ) bin=$bin md5=$(md5sum < $bin | cut -c1-32) corpora=$*" > "$wd.log"
bash tests/sweep.sh --jobs 3 --workdir "$wd" --corpus "$*" >> "$wd.log" 2>&1
echo "EXIT=$? END $(date -u +%FT%TZ)" >> "$wd.log"

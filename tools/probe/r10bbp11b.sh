#!/bin/bash
# r10bbp11b: incremental build of the worktree binary, quiet except errors.
W=${W:-$PWD}
cd "$W" || exit 1
L=${1:-/tmp/r10bbp11_build.log}
timeout 590 ~/.local/bin/cmake --build build -j 3 > "$L" 2>&1
rc=$?
echo "BUILD_EXIT=$rc"
grep -E "error:|Error" "$L" | head -20
tail -2 "$L"

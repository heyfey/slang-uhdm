#!/usr/bin/env bash
# r10vbuvm31repro/vbuild31.sh — configure + build ONE worktree, -j 2 only, and
# print the md5.  Every path is an argument: this driver hard-codes none.
#   vbuild31.sh <worktree> [build subdir]
set -u
W=${1:?worktree}; B=${2:-build}
cmake -S "$W" -B "$W/$B" -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
      > "$W/$B.cfg.log" 2>&1
echo "cfg rc=$?"
timeout 3000 cmake --build "$W/$B" -j 2 > "$W/$B.build.log" 2>&1
echo "build rc=$?"
grep -E ' error |Built target slang_uhdm$' "$W/$B.build.log" | tail -3
md5sum "$W/$B/slang-uhdm"

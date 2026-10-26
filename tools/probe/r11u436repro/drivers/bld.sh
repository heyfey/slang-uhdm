#!/bin/bash
# bld.sh <tag>: build the worktree; on success freeze build/slang-uhdm as /tmp/r11u436_bin/<tag>
cd /tmp/wt_r11u436 || exit 1
if cmake --build build -j 2 > /tmp/r11u436_scratch/bld_$1.log 2>&1; then
  rm -f /tmp/r11u436_bin/$1; cp build/slang-uhdm /tmp/r11u436_bin/$1 && chmod 555 /tmp/r11u436_bin/$1 && md5sum /tmp/r11u436_bin/$1
else grep -E ' error' /tmp/r11u436_scratch/bld_$1.log | head; exit 1; fi

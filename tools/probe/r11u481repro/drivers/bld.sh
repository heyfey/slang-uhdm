#!/bin/bash
# build the worktree and freeze the binary as /tmp/r11u481_bin/$1 only on success
cd /tmp/wt_r11u481 && cmake --build build -j 2 > /tmp/r11u481_bld_$1.log 2>&1 || { grep -E 'error' -A3 /tmp/r11u481_bld_$1.log | head -20; echo BUILD FAILED; exit 1; }
rm -f /tmp/r11u481_bin/$1; cp build/slang-uhdm /tmp/r11u481_bin/$1 && chmod 555 /tmp/r11u481_bin/$1 && md5sum /tmp/r11u481_bin/$1

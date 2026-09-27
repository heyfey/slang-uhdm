#!/bin/bash
for x in A B; do cd /tmp/wt_r11u189$x && cmake -B build -DCMAKE_BUILD_TYPE=Release -DSLANG_UHDM_USE_SYSTEM_DEPS=ON -DCMAKE_PREFIX_PATH=$HOME/.local > /tmp/r11u189_cmake$x.log 2>&1 && cmake --build build -j 2 --target slang_uhdm > /tmp/r11u189_build$x.log 2>&1; echo BUILD_RC=$? >> /tmp/r11u189_build$x.log; done

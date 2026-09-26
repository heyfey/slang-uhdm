#!/bin/bash
d=$1
cd $d && cmake -B build -DCMAKE_BUILD_TYPE=Release -DSLANG_UHDM_USE_SYSTEM_DEPS=ON -DCMAKE_PREFIX_PATH=$HOME/.local > build.cfg.log 2>&1 && cmake --build build -j 2 > build.log 2>&1; echo "rc=$?" >> build.log

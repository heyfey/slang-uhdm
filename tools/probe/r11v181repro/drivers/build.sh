#!/bin/bash
wt=$1; n=$(basename $wt)
cd $wt && cmake -B build -DCMAKE_BUILD_TYPE=Release -DSLANG_UHDM_USE_SYSTEM_DEPS=ON -DCMAKE_PREFIX_PATH=$HOME/.local > /tmp/v11u181_cmake_$n.log 2>&1 && cmake --build build -j 2 > /tmp/v11u181_build_$n.log 2>&1; echo "rc=$?" >> /tmp/v11u181_build_$n.log

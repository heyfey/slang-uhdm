#!/bin/bash
set -e
for d in /tmp/wt_v11u186pris /tmp/wt_v11u186; do
  cd $d
  cmake -B build -DCMAKE_BUILD_TYPE=Release -DSLANG_UHDM_USE_SYSTEM_DEPS=ON -DCMAKE_PREFIX_PATH=$HOME/.local > /tmp/v11u186_cmake_$(basename $d).log 2>&1
  cmake --build build -j 2 > /tmp/v11u186_build_$(basename $d).log 2>&1
  echo "built $d $(md5sum build/slang-uhdm)"
done

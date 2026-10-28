#!/bin/bash
/tmp/wt_v11u452/tools/probe/v11u452repro/drivers/quiet.sh
date > /tmp/v11u452_build.start
cd /tmp/wt_v11u452 && cmake -B build -DCMAKE_BUILD_TYPE=Release -DSLANG_UHDM_USE_SYSTEM_DEPS=ON -DCMAKE_PREFIX_PATH=$HOME/.local > /tmp/v11u452_build.log 2>&1 && cmake --build build -j 2 >> /tmp/v11u452_build.log 2>&1
echo rc=$? >> /tmp/v11u452_build.log
cp /tmp/wt_v11u452/build/slang-uhdm /tmp/v11u452_bin/law && chmod a-w /tmp/v11u452_bin/law
md5sum /tmp/v11u452_bin/law >> /tmp/v11u452_build.log
date > /tmp/v11u452_build.done

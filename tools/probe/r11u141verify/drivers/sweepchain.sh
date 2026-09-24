#!/bin/bash
# sweepchain.sh TAG:ENV1,ENV2:CORPORA ...   sequential sweeps from the worktree with the frozen binary
source /tmp/r11u141_drv/env.sh
cd /tmp/wt_r11u141
for spec in "$@"; do
  tag=${spec%%:*}; rest=${spec#*:}; envs=${rest%%:*}; corp=${rest#*:}
  wd=/tmp/r11u141_wd$tag; rm -rf $wd; mkdir -p $wd
  echo "tag=$tag env=$envs corpora=$corp bin=$SLANG_UHDM start=$(date -Is)" > $wd/CONFIG
  ( for kv in ${envs//,/ }; do export $kv=1; done
    env | grep -E '^R11[UV]13' >> $wd/CONFIG
    tests/sweep.sh --jobs 3 --workdir $wd --corpus "$corp" > $wd/sweep.log 2>&1; echo "rc=$?" >> $wd/CONFIG )
  echo "end=$(date -Is)" >> $wd/CONFIG
done

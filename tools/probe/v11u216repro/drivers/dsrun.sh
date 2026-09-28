#!/bin/bash
# v11u216: downstream verdicts of this directory's single-file cases (T, F) with each frozen binary in turn,
# fresh GOLDEN_CACHE under /tmp/v11u216_dsg, work roots /tmp/v11u216_dsw_<bin>.  usage: dsrun.sh <bin>... > out.txt
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
CS=$(find $HERE/../cases -name dut.sv -printf '%h\n' | sort | while read c; do [ -f $c/args ] || echo $c; done)
for b in "$@"; do
  mkdir -p /tmp/v11u216_dsw_$b /tmp/v11u216_dsg
  SLANG_UHDM=$B/$b GOLDEN_CACHE=/tmp/v11u216_dsg python3 $HERE/dsfaces.py /tmp/v11u216_dsw_$b $CS | sed "s/^/$b /"
done

#!/bin/bash
# upstream.sh <out>: upstream slang's real exit code on every case of this pass
D=$(dirname "$0"); : > $1
for c in $(find $D/../cases -mindepth 2 -maxdepth 2 -type d | sort); do
  (cd $c && ~/.local/bin/slang dut.sv --single-unit -q >/dev/null 2>&1 </dev/null); echo "${c#*/cases/} upstream_rc=$?" >> $1
done

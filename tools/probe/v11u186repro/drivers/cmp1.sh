#!/bin/bash
# usage: cmp1.sh <case rel e.g. D/x03> [bins...]; prints uhdm-cmp head of each bin
. /tmp/v11u186_env.sh
c=$1; shift; d=/tmp/v11u186_cases/$c
k=$(cd $d && python3 -c "
import hashlib,os
h=hashlib.md5()
for f in sorted(os.listdir('.')):
  if f.endswith(('.sv','.svh','.v','.vh')): h.update(f.encode()); h.update(open(f,'rb').read())
print(h.hexdigest()[:16])")
G=/tmp/v11u186_gold/$k/golden.uhdm
for b in ${@:-pris law}; do echo "== $b"; $UHDM_CMP $G ${GD:-/tmp/v11u186_g1}/$b.bin/_tmp_v11u186_cases_${c/\//_}/ours.uhdm 2>&1 | grep -v '^\s*$' | head -${N:-40}; done

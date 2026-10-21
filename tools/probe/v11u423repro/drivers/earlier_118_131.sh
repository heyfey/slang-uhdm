#!/bin/bash
# v11u423 earlier-pass census: pristine vs law bytes and exit code on every fence-filtered case dir
# under tools/probe/{r11u4??,v11u4??}repro (passes 401..422).  usage: earlier.sh <pristine> <law> <out>
P=$1; F=$2; OUT=$3; T=/tmp/v11u423_early; mkdir -p $T
cd /tmp/wt_v11u423/tools/probe
python3 - > $T/list.txt <<'PY'
import os,glob,re
fence=[l.strip() for l in open('/tmp/v11u423_fence.txt') if l.strip()]
ds=[]
for d in sorted([x for x in ['r11u118repro','r11v11u118repro','r11u119repro','r11u120repro','r11v120repro','r11u124repro','r11v124repro','r11u125repro','r11u130repro','r11u131repro','r11v131repro'] if os.path.isdir(x)]):
    if d.startswith(('r11u423','v11u423')): continue
    for dp,dn,fn in os.walk(d):
        if 'dut.sv' in fn and not any(x in dp for x in fence): ds.append(dp)
print('\n'.join(ds))
PY
one() { c=$1; k=$(echo $c | md5sum | cut -c1-12); TL=""; [ -f $c/TOP ] && TL="--top $(cat $c/TOP)"
  rm -f $T/p_$k.uhdm $T/f_$k.uhdm
  (cd $c && timeout 120 $P dut.sv $TL --single-unit --nobuiltin -o $T/p_$k.uhdm >/dev/null 2>&1); rp=$?
  (cd $c && timeout 120 $F dut.sv $TL --single-unit --nobuiltin -o $T/f_$k.uhdm >/dev/null 2>&1); rf=$?
  mp=$(md5sum < $T/p_$k.uhdm 2>/dev/null | cut -c1-8); mf=$(md5sum < $T/f_$k.uhdm 2>/dev/null | cut -c1-8)
  echo "$c rc=$rp/$rf $([ "$rp:$mp" = "$rf:$mf" ] && echo same || echo MOVED)"; }
export -f one; export P F T
cat $T/list.txt | xargs -P 3 -I{} bash -c 'one {}' > $OUT

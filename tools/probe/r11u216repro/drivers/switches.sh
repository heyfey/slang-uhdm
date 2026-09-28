#!/bin/bash
# r11u216: each law's own switch on its own family, both views: the law binary under the switch against pristine bytes.
# prints <case-view> <switch> same|DIFF (DIFF = the switch leaves bytes other than pristine's).  Fence via case.sh.
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
chk() { fam=$1; shift; sws="$*"
  for c in $(ls -d $HERE/../cases/$fam/*/); do for el in 0 1; do
    p=$(EL=$el bash $HERE/case.sh $c pristine.bin $B/pristine.bin 2>/dev/null | grep -o 'md5=[0-9a-f]*')
    e=""; for s in $sws; do e="$e $s=1"; done
    o=$(EL=$el bash $HERE/case.sh $c sw_law.bin $B/law.bin $e 2>/dev/null | grep -o 'md5=[0-9a-f]*')
    n=$(basename $c); [ $el = 1 ] && n=${n}_el
    [ "$p" = "$o" ] && echo "$fam/$n $sws same" || echo "$fam/$n $sws DIFF"; done; done; }
chk GQ R11U216_GENRQFOLD_OFF
chk NQ R11U216_NDARQFOLD_OFF R11U216_NDASIZEFOLD_OFF
chk TW R11U216_TFOUTCLS_OFF

#!/bin/bash
# boundary.sh <outdir>: every tools/probe/**/dut.sv (base tree, pristine worktree copy; the r11u176repro cases are separate),
# exported by pris / law(final4) / ver2, databases compared byte for byte; fenced paths refused (fail closed).
set -u; O=$1; mkdir -p $O/db; source /tmp/v11u176_env.sh
R=/tmp/wt_v11u176pris
fre=$(echo $FENCED | sed 's/ /\\|/g')
find $R/tools/probe -name dut.sv | grep -vw "$fre" | sort > $O/list.txt
one() { d=$(dirname $1); k=$(echo $d | sed "s|$R/||; s|/|__|g"); r=""
  for t in P:pris L:law V:ver2; do
    rm -f $O/db/$k.${t%%:*}.uhdm
    (cd $d && timeout 120 /tmp/v11u176_bin/${t#*:}.bin dut.sv --single-unit --nobuiltin -o $O/db/$k.${t%%:*}.uhdm >/dev/null 2>&1 </dev/null); r="$r ${t%%:*}rc=$?"
  done
  P=$O/db/$k.P.uhdm; L=$O/db/$k.L.uhdm; V=$O/db/$k.V.uhdm
  pl=$( [ -s $P ] && [ -s $L ] && cmp -s $P $L && echo same || { [ -s $P ] || [ -s $L ] && echo MOVER || echo nodb; } )
  lv=$( [ -s $V ] && [ -s $L ] && cmp -s $V $L && echo same || { [ -s $V ] || [ -s $L ] && echo MOVER || echo nodb; } )
  echo "PL=$pl LV=$lv $d$r"
  [ "$pl" = same ] && [ "$lv" = same ] && rm -f $P $L $V; true; }
export -f one; export O R
xargs -a $O/list.txt -P 3 -I{} bash -c 'one {}' > $O/result.txt
echo "listed $(wc -l < $O/list.txt) processed $(wc -l < $O/result.txt)"

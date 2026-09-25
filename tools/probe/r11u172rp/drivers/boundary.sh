#!/bin/bash
# boundary.sh <pristine bin> <law bin> <out> : byte boundary over every tools/probe/**/dut.sv (the evidence grids of
# earlier passes) except this pass's own; each case exported with `dut.sv --single-unit --nobuiltin` by both binaries,
# databases compared byte for byte.  Refuses a case whose path names a fenced test (word boundary, $FENCED).
P=$1 L=$2 OUTF=$3
: "${FENCED:?FENCED unset}"; [ "$(echo $FENCED | wc -w)" = 4 ] || exit 3
fre=$(echo $FENCED | sed 's/ /|/g'); R=/tmp/wt_r11u172
one() {
  c=$1; k=$(echo $c | md5sum | cut -c1-12); T=/tmp/r11u172_bnd; mkdir -p $T
  rm -f $T/$k.p $T/$k.l
  (cd $R/$c && timeout 120 $P dut.sv --single-unit --nobuiltin -o $T/$k.p >/dev/null 2>&1 </dev/null; timeout 120 $L dut.sv --single-unit --nobuiltin -o $T/$k.l >/dev/null 2>&1 </dev/null)
  if [ ! -e $T/$k.p ] && [ ! -e $T/$k.l ]; then echo "NODB $c"; elif cmp -s $T/$k.p $T/$k.l; then echo "SAME $c"; else echo "MOVER $c"; fi
  rm -f $T/$k.p $T/$k.l
}
export -f one; export P L R
(cd $R && find tools/probe -name dut.sv -not -path '*/r11u172rp/*' | sort | xargs -n1 dirname) | grep -vEw "$fre" | xargs -P 3 -I{} bash -c 'one {}' > $OUTF
echo "listed=$(cd $R && find tools/probe -name dut.sv -not -path '*/r11u172rp/*' | wc -l) processed=$(wc -l < $OUTF) $(cut -d' ' -f1 $OUTF | sort | uniq -c | tr '\n' ' ')"

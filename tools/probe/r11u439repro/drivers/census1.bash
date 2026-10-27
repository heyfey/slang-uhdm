#!/bin/bash
# census1.bash <rel dut.sv under tools/probe>: pristine vs law7 bytes and exit code, same output path
rel=$1; src=/home/heyfey/git-repos/slang-uhdm/tools/probe/$rel; dir=$(dirname $src)
key=$(echo $rel | tr '/' '_'); w=/tmp/r11u439_census/$key; mkdir -p $w
for b in p l; do
  bin=/tmp/r11u439_pris.bin; [ $b = l ] && bin=/tmp/r11u439_bin/law7
  rm -f $w/out.uhdm
  (cd $dir && timeout 300 $bin dut.sv --single-unit --nobuiltin -o $w/out.uhdm >/dev/null 2>&1 </dev/null); echo $? > $w/$b.rc
  if [ -f $w/out.uhdm ]; then mv $w/out.uhdm $w/$b.uhdm; else rm -f $w/$b.uhdm; fi
done
if cmp -s $w/p.rc $w/l.rc && { { [ ! -f $w/p.uhdm ] && [ ! -f $w/l.uhdm ]; } || cmp -s $w/p.uhdm $w/l.uhdm; }; then echo "SAME $rel $(cat $w/l.rc)"; rm -f $w/p.uhdm $w/l.uhdm; else echo "MOVER $rel $(cat $w/p.rc) $(cat $w/l.rc)"; fi

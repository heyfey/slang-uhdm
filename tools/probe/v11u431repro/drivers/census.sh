#!/bin/bash
# census.sh <list> <out>: run pristine and law on every case dir of the list to the SAME output path
# (a database embeds its output path), record rc and md5 of each; one line per dir
L=${CEN_NEW:-/tmp/v11u431_law/slang-uhdm}; P=${CEN_OLD:-/tmp/v11u431_pris/slang-uhdm}
for v in "$L" "$P"; do [ -x "$v" ] || { echo "missing $v"; exit 2; }; done
one() { c=$1; key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g"); d=${CEN_DIR:-/tmp/v11u431_cen}/$key; mkdir -p $d
  SRC=dut.sv; [ -f $c/FILES ] && SRC=$(cat $c/FILES); GT=; [ -f $c/TOP ] && GT="--top $(cat $c/TOP)"
  rm -f $d/o.uhdm; (cd $c && timeout 300 $P $SRC $GT --single-unit --nobuiltin -o $d/o.uhdm >/dev/null 2>&1); rp=$?; mp=$(md5sum < $d/o.uhdm 2>/dev/null | cut -c1-12); [ -f $d/o.uhdm ] && mv $d/o.uhdm $d/p.uhdm
  rm -f $d/o.uhdm; (cd $c && timeout 300 $L $SRC $GT --single-unit --nobuiltin -o $d/o.uhdm >/dev/null 2>&1); rl=$?; ml=$(md5sum < $d/o.uhdm 2>/dev/null | cut -c1-12); [ -f $d/o.uhdm ] && mv $d/o.uhdm $d/l.uhdm
  if [ "$rp" = "$rl" ] && [ "$mp" = "$ml" ]; then echo "SAME $key rc=$rp"; rm -f $d/p.uhdm $d/l.uhdm; else echo "MOVER $key rc=$rp/$rl"; fi; }
export -f one; export L P CEN_DIR
cat $1 | xargs -P 3 -I{} bash -c 'one {}' > $2.unsorted; sort $2.unsorted > $2; rm $2.unsorted; echo CENSUSDONE

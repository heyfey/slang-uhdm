#!/bin/bash
# bytes.sh <pristine bin> <law bin> <pass dir>...: every dut.sv case under each dir, both binaries
# (probe flags), byte comparison; prints per dir "movers/cases" and each mover with its census firing.
P=$1; L=$2; shift 2
T=/tmp/r11u147_bytes; mkdir -p $T
one(){ d=$(dirname $1); k=$(echo $d | md5sum | cut -c1-12)
  (cd $d && $P dut.sv --single-unit --nobuiltin -o $T/$k.p.uhdm >/dev/null 2>&1; echo $? > $T/$k.p.rc)
  (cd $d && R11U147_TRACE=1 R11U151_TRACE=1 $L dut.sv --single-unit --nobuiltin -o $T/$k.l.uhdm 2>$T/$k.l.err >/dev/null; echo $? > $T/$k.l.rc)
  if [ -f $T/$k.p.uhdm ] || [ -f $T/$k.l.uhdm ]; then
    cmp -s $T/$k.p.uhdm $T/$k.l.uhdm && s=SAME || s=MOVER; else s=NODB; fi
  f=$(grep -Eo '^(R11U147_TRACE|R11U151) [A-Za-z0-9]*' $T/$k.l.err | awk '{print $2}' | sort -u | tr '\n' ' ')
  echo "$s $d rc=$(cat $T/$k.p.rc)/$(cat $T/$k.l.rc) fires=[$f]"; rm -f $T/$k.*; }
export -f one; export P L T
# The fence: fail closed unless $FENCED holds the four slang-fenced test names; any case whose
# path names one of them (word boundary) is never dispatched.
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "bytes.sh: export FENCED (the four names) first"; exit 2; }
fre=$(echo $FENCED | sed 's/ /|/g')
for dir in "$@"; do
  find $dir -name dut.sv | grep -Evw "$fre" | sort | xargs -P 3 -I{} bash -c 'one {}' > $T/res.txt
  echo "== $(basename $dir): $(grep -c '^MOVER' $T/res.txt)/$(wc -l < $T/res.txt) movers, $(grep -c 'fires=\[[A-Z]' $T/res.txt) firing"
  grep -E '^MOVER|^NODB|fires=\[[A-Z]' $T/res.txt | sed "s#^#  #"
done

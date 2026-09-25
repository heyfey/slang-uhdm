#!/bin/bash
# bytes.sh <dir>...: pristine vs fix1 on every dut.sv case (probe flags); fence-filtered (fail closed)
source /tmp/v11u147_env.sh
[ "$(echo $FENCED | wc -w)" = 4 ] || { echo "export FENCED first"; exit 2; }
fre=$(echo $FENCED | sed 's/ /|/g')
one(){ d=$(dirname $1); k=$(echo $d | md5sum | cut -c1-12); T=/tmp/v11u147_bytes
  (cd $d && /tmp/v11u147_bin/pris dut.sv --single-unit --nobuiltin -o $T/$k.p.uhdm >/dev/null 2>&1; echo $? > $T/$k.p.rc)
  (cd $d && R11U147_TRACE=1 R11U151_TRACE=1 /tmp/v11u147_bin/fix1 dut.sv --single-unit --nobuiltin -o $T/$k.l.uhdm 2>$T/$k.l.err >/dev/null; echo $? > $T/$k.l.rc)
  if [ -f $T/$k.p.uhdm ] || [ -f $T/$k.l.uhdm ]; then cmp -s $T/$k.p.uhdm $T/$k.l.uhdm && s=SAME || s=MOVER; else s=NODB; fi
  f=$(grep -Eo '^(R11U147_TRACE|R11U151) [A-Za-z0-9-]*' $T/$k.l.err | awk '{print $2}' | sort -u | tr '\n' ' ')
  echo "$s $d rc=$(cat $T/$k.p.rc)/$(cat $T/$k.l.rc) fires=[$f]"; rm -f $T/$k.*; }
export -f one; mkdir -p /tmp/v11u147_bytes
for dir in "$@"; do
  find $dir -name dut.sv | grep -Evw "$fre" | sort | xargs -P 3 -I{} bash -c 'one {}' > /tmp/v11u147_bytes/res.txt
  echo "== $(basename $dir): $(grep -c '^MOVER' /tmp/v11u147_bytes/res.txt)/$(wc -l < /tmp/v11u147_bytes/res.txt) movers"
  grep -E '^MOVER|^NODB' /tmp/v11u147_bytes/res.txt | sed "s#^#  #"
done

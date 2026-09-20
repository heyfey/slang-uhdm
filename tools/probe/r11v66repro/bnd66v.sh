#!/bin/bash
# v11u66 WIDE BOUNDARY — every committed probe arm that contains an assignment
# pattern, compiled by BOTH frozen binaries IN THE SAME DIRECTORY with the SAME
# output name, so the absolute path the serializer embeds is byte-identical and
# the databases are directly comparable.  usage: bnd66v.sh <relative .sv path>
set -u
F="$1"
K=$(echo "$F" | tr '/.' '__')
O=/tmp/v11u66_bnd/w/$K
rm -rf "$O"; mkdir -p "$O"
( cd "$O" && timeout 120 /tmp/v11u66_bin/pris.bin "/tmp/wt_v11u66/tools/probe/$F" --single-unit -o d.uhdm > plog 2>&1 ); prc=$?
pm=NONE; [ -f "$O/d.uhdm" ] && { pm=$(md5sum "$O/d.uhdm" | cut -c1-12); mv "$O/d.uhdm" "$O/p.uhdm"; }
( cd "$O" && timeout 120 /tmp/v11u66_bin/law.bin  "/tmp/wt_v11u66/tools/probe/$F" --single-unit -o d.uhdm > llog 2>&1 ); lrc=$?
lm=NONE; [ -f "$O/d.uhdm" ] && { lm=$(md5sum "$O/d.uhdm" | cut -c1-12); mv "$O/d.uhdm" "$O/l.uhdm"; }
if [ "$prc" != "$lrc" ]; then
  echo "RCDIFF $F prc=$prc lrc=$lrc"
elif [ "$pm" != "$lm" ]; then
  echo "MOVER $F prc=$prc p=$pm l=$lm"
else
  echo "SAME $F prc=$prc db=$pm"
  rm -rf "$O"
fi

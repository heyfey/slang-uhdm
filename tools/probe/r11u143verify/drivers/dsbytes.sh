#!/bin/bash
# dsbytes.sh <downstream workdir> <tag> <tests...>: md5 of the three Yosys outputs per lane; SAME when all three match
W=$1; tag=$2; shift 2
for t in "$@"; do
  s=""; ok=1
  for f in _nohier.il .il _synth.v; do
    a=$(md5sum < $W/$t/surelog/$t$f 2>/dev/null | cut -c1-12); b=$(md5sum < $W/$t/slanguh/$t$f 2>/dev/null | cut -c1-12)
    [ -n "$a" ] && [ "$a" = "$b" ] || ok=0; s="$s ${f#_}:$a=$b"
  done
  echo "$tag $t $([ $ok = 1 ] && echo BYTE-IDENTICAL || echo DIFFER)$s | $(grep "^$t," /tmp/r11u143_wdON/downstream.csv)"
done

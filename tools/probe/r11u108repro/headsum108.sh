#!/bin/bash
# headsum108.sh <out-root> <tag>: per arm, cmp lines/heads and the first object line of LHS and RHS
OUT=${1:?}; TAG=${2:?}
for c in $(cd "$OUT" && find . -name "$TAG.cmp" | sort); do
  a=$(dirname "${c#./}"); f="$OUT/$c"
  l=$(awk '/^LHS:/{getline; if($0=="decompile:")getline; print; exit}' "$f")
  r=$(awk '/^RHS:/{x=$0; sub(/^RHS: */,"",x); if(x!=""){print x; exit} getline; if($0=="decompile:")getline; print; exit}' "$f")
  echo "$a $(wc -l < "$f")/$(grep -c '^LHS:' "$f"; true) | L: ${l:0:90} | R: ${r:0:90}"
done

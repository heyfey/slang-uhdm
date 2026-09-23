#!/bin/bash
# cenvrun110.sh <sweep-workdir> — cenv110 on every row's GOLDEN database
# (cmds.txt cache-hit line) and on our slang.uhdm; prints rows with a nonzero
# count on either side.  List read on fd 3.
WD=${1:?workdir}
CEN=${CENV110:-$(dirname "$0")/cenv110}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
n=0
while read -r c <&3; do
  d=$(dirname "$c"); n=$((n+1))
  g=$(sed -n 's/^surelog: *(golden cache hit \(.*\))$/\1/p' "$c")
  gs=NA; os=NA
  [ -n "$g" ] && [ -f "$g/golden.uhdm" ] && gs=$(timeout 300 "$CEN" "$g/golden.uhdm" </dev/null | tail -1 | sed 's/TOTAL //')
  [ -f "$d/slang.uhdm" ] && os=$(timeout 300 "$CEN" "$d/slang.uhdm" </dev/null | tail -1 | sed 's/TOTAL //')
  if { [ "$gs" != 0 ] && [ "$gs" != NA ]; } || { [ "$os" != 0 ] && [ "$os" != NA ]; }; then
    echo "ROW ${d#$WD/} GOLD $gs OURS $os"
  fi
done 3< <(find "$WD" -name cmds.txt | sort)
echo "PROCESSED=$n"

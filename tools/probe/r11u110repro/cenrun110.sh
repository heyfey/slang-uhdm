#!/bin/bash
# cenrun110.sh <sweep-workdir> [ours-tag-name]
# For every row dir (<wd>/<corpus-part>/<mode>/<row>/cmds.txt) runs cen110 on
# the GOLDEN database named by the cmds.txt cache-hit line and on our
# slang.uhdm, and prints "<mode>/<row> GOLD n OURS m" for rows with a nonzero
# count on either side, followed by the cells.  List read on fd 3.
WD=${1:?workdir}
CEN=${CEN110:-$(dirname "$0")/cen110}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
n=0
while read -r c <&3; do
  d=$(dirname "$c"); n=$((n+1))
  g=$(sed -n 's/^surelog: *(golden cache hit \(.*\))$/\1/p' "$c")
  gs=NA; os=NA
  [ -n "$g" ] && [ -f "$g/golden.uhdm" ] && gs=$("$CEN" "$g/golden.uhdm" </dev/null | tail -1 | sed 's/.*SHAPE=//')
  [ -f "$d/slang.uhdm" ] && os=$("$CEN" "$d/slang.uhdm" </dev/null | tail -1 | sed 's/.*SHAPE=//')
  if [ "$gs" != 0 ] && [ "$gs" != NA ] || [ "$os" != 0 ] && [ "$os" != NA ]; then
    echo "ROW ${d#$WD/} GOLD $gs OURS $os"
  fi
done 3< <(find "$WD" -name cmds.txt | sort)
echo "PROCESSED=$n"

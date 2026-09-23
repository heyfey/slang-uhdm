#!/bin/bash
# cenmrun110.sh <sweep-workdir> — r11u108's cenm108 (DEF package listing
# struct/union members) on every row's GOLDEN database and on our
# slang.uhdm; prints rows whose member-line SETS differ, with the member
# keys whose golden binding is a NAMED pkg::T logic_typespec that ours lacks.
WD=${1:?workdir}
CEN=${CENM108:?cenm108 binary}
export LD_LIBRARY_PATH=$HOME/.local/lib64:$HOME/.local/lib
n=0
while read -r c <&3; do
  d=$(dirname "$c"); n=$((n+1))
  g=$(sed -n 's/^surelog: *(golden cache hit \(.*\))$/\1/p' "$c")
  [ -n "$g" ] && [ -f "$g/golden.uhdm" ] && [ -f "$d/slang.uhdm" ] || continue
  gl=$(timeout 600 "$CEN" "$g/golden.uhdm" </dev/null | sort -u)
  ol=$(timeout 600 "$CEN" "$d/slang.uhdm" </dev/null | sort -u)
  [ -z "$gl" ] && [ -z "$ol" ] && continue
  miss=$(comm -23 <(echo "$gl") <(echo "$ol") | grep -c 'logic_typespec name=[A-Za-z0-9_]*::'; true)
  [ "$miss" != 0 ] && echo "ROW ${d#$WD/} GOLD-ONLY-NAMED-BINDINGS $miss"
done 3< <(find "$WD" -name cmds.txt | sort)
echo "PROCESSED=$n"

#!/bin/bash
# away.sh <law svtests workroot> <pristine svtests workroot> <row list> : for each sv-tests row the law
# fired on and that is not EQUAL under the law, the normalised uhdm-dump distance (diff lines) to
# Surelog's kept golden for the pristine and the law database (workroot paths normalised).
D=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$D" ] || exit 2
L=$1; P=$2
norm() { $D $1 2>/dev/null | sed 1d | sed -E 's@/tmp/[A-Za-z0-9_]+/(svtests/)?work/@W/@g'; }
while read -r r; do
  g=$L/$r/slpp_all/surelog.uhdm; [ -f $g ] || g=$P/$r/slpp_all/surelog.uhdm
  if [ ! -f $g ]; then c=$(sed -n '1s/.*golden cache hit \([^)]*\)).*/\1/p' $L/$r/cmds.txt); g=$c/golden.uhdm; fi
  [ -f $L/$r/slang.uhdm ] && [ -f $P/$r/slang.uhdm ] && [ -f $g ] || { echo "$r SKIP(no kept pair)"; continue; }
  dp=$(diff <(norm $g) <(norm $P/$r/slang.uhdm) | grep -c '^[<>]'); dl=$(diff <(norm $g) <(norm $L/$r/slang.uhdm) | grep -c '^[<>]')
  v=same; [ $dl -lt $dp ] && v=toward; [ $dl -gt $dp ] && v=AWAY
  echo "$r pristine=$dp law=$dl $v"
done < $3

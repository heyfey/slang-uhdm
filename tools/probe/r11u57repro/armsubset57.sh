#!/usr/bin/env bash
# r11u57 ARM SUBSET — per grid arm, the judge-reachable divergence SET against
# golden under two binaries, and every divergence text the second binary
# introduces.
#
# `toward57.sh` gives the arm's residue COUNT, which can fall while a new wrong
# cell appears.  This prints the new texts themselves.  On a deliberately-moved
# arm a non-zero count is NOT automatically a failure — an object that changes
# kind brings its own field lines with it — so every entry is printed and named
# in the README rather than summed.
#
#   usage: armsubset57.sh <tagA> <tagB> [arms...]
set -u
R=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
A=${1:?tagA}; B=${2:?tagB}; shift 2
DUMP=${DUMP:-/home/heyfey/git-repos/UHDM/build/bin/uhdm-dump}
ARMS=${*:-$(ls -d $R/grid/*/ | xargs -n1 basename | sort -V)}
sec() { awk '/uhdmall(Modules|Packages|Classes):/{f=1} /weaklyReferenced:/{f=0} f' "$1"; }
norm() { sed 's/, id:[0-9]*//g; s/id:[0-9]*//g; s/  */ /g'; }
for a in $ARMS; do
  d=$R/grid/$a
  g=$d/slpp_all/surelog.uhdm
  [ -f "$g" ] || { echo "$a NO-GOLDEN"; continue; }
  t=$(mktemp -d)
  $DUMP "$g" 2>/dev/null | sed -e "s#$d/##g" > $t/g
  sec $t/g | sort > $t/gs
  for x in $A $B; do
    o=$d/ours.$x.uhdm
    [ -f "$o" ] || { : > $t/$x.d; continue; }
    $DUMP "$o" 2>/dev/null | sed -e "s#$d/##g" > $t/$x
    sec $t/$x | sort > $t/$x.s
    diff $t/gs $t/$x.s > $t/$x.d; true
  done
  grep -E '^[<>]' $t/$A.d | norm | sort -u > $t/at
  grep -E '^[<>]' $t/$B.d | norm | sort -u > $t/bt
  new=$(comm -13 $t/at $t/bt | grep -c .; true)
  gone=$(comm -23 $t/at $t/bt | grep -c .; true)
  echo "$a  judge-diff $A=$(grep -cE '^[<>]' $t/$A.d; true) $B=$(grep -cE '^[<>]' $t/$B.d; true)  texts cleared=$gone new=$new"
  [ "$new" != 0 ] && comm -13 $t/at $t/bt | sed 's/^/    NEW /'
  rm -rf $t
done

#!/bin/bash
# r11u157: for every case of a grid out root with a DIFF path in hpsig.txt, run ourpin.sh and print the pinned paths at
# the DIFF keys (golden mint + our mint). args: <cases root> <out root>
set -u
D=$(cd "$(dirname "$0")" && pwd); R=$1; O=$2
for h in $(find "$O" -name hpsig.txt | sort); do
  o=$(dirname "$h"); rel=$(realpath --relative-to="$O" "$o"); c=$R/$rel
  grep -q '^DIFF' "$h" || continue
  [ -s "$o/ourpin/g1.objtab" ] || bash "$D/ourpin.sh" "$c" "$o/ourpin" > "$o/ourpin.txt" 2>/dev/null < /dev/null
  echo "=== $rel"
  grep '^DIFF' "$h" | while read -r st key name rest; do
    ln=${key%%:*}; col=${key##*:}
    echo "  $st $key $name ${rest:0:160}"
    awk -v k=" $ln:$col:" '/^P/{on=index($0,k)>0} on' "$o/pin.txt" | sed 's/^/     G /' | cut -c1-200 | head -8
    awk -v k=" $ln:$col:" '/^P/{on=index($0,k)>0} on' "$o/ourpin.txt" | sed 's/^/     O /' | cut -c1-230 | head -8
  done
done

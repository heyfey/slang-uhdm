#!/bin/bash
# bindcmp.sh <casedir>: call-binding multiset distance golden vs pris / law
c=$(cd $1 && pwd); h=$(cat $(ls -d $c/* | sort) | md5sum | cut -c1-12)
key=$(echo $c | sed "s|.*/tools/probe/||; s|/|_|g")
g=/tmp/v11u446_scr/gold/$h/slpp_all/surelog.uhdm; B=/tmp/v11u446_tools/bind
o=/tmp/v11u446_scr/out/$key; [ -f $g ] || { echo "$key NOGOLD"; exit; }
$B $g > $o/g.bind
r="$key"
for t in pris law ${EXTRA}; do [ -f $o/$t/ours.uhdm ] || continue; $B $o/$t/ours.uhdm > $o/$t/o.bind; r="$r $t=$(diff $o/g.bind $o/$t/o.bind | grep -c '^[<>]')"; done
echo "$r ncalls=$(wc -l < $o/g.bind)"

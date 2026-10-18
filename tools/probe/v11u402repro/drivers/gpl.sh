#!/bin/bash
# gpl.sh <casesroot> <rel> <gridtag> : golden-vs-pristine and golden-vs-law dump diffs (ids, dirs stripped)
. /tmp/v11u402_env.sh
d=$2; c=/tmp/v11u402_gw_$3/$(echo $d|tr / _); h=$(cat $1/$d/*.sv | md5sum | cut -c1-12); g=/tmp/v11u402_gold/$h/slpp_all/surelog.uhdm
n(){ $UHDM_DUMP $1 2>/dev/null | sed -E 's/id:[0-9]+/id:/; s#/[^ ,]*/##g' | grep -v 'Restored design'; }
n $g > $c/g.d; n $c/p.uhdm > $c/p.d; n $c/l.uhdm > $c/l.d
echo "### G vs P ($(diff $c/g.d $c/p.d | grep -c '^[<>]') lines)"; diff $c/g.d $c/p.d | head -${N:-40}
echo "### G vs L ($(diff $c/g.d $c/l.d | grep -c '^[<>]') lines)"; diff $c/g.d $c/l.d | head -${N:-40}

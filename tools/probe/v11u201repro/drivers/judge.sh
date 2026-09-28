#!/bin/bash
# v11u201: judge.sh "<bin names in $VB>" <case dir>...  -> <case> <verdict per bin>[=]  (= : bytes equal to previous bin)
# env ELAB=1, XENV (applied to every bin), TAG (outdir tag)
. "$(cd "$(dirname "$0")" && pwd)/env.sh" || exit 3
BINS=$1; shift
one() { c=$1; k=$(echo "$c${ELAB:-}${XENV:-}" | md5sum | cut -c1-10); prev=; line="$(echo $c | sed 's#.*/tools/probe/##; s#.*/tests/probe/##; s#.*/v11u201_cases/##')"
  for b in $BINS; do o=/tmp/v11u201_judge/${TAG:-x}/$b/$k; r=$(SLANG_UHDM=$VB/$b bash $V201DRV/case.sh $c $o 2>/dev/null)
    v=$(awk '{ if ($1=="SLANG_FAIL"||$1=="SURELOG_FAIL") print $1; else if ($3=="STRICT_EQUAL") print "EQUAL"; else if ($3=="NOT_EQUAL"||$3=="") print "NOT_EQUAL"; else print "S:"$4 }' <<< "$r")
    n=$(grep -o 'objects_differing=[0-9]*' $o/strict.txt 2>/dev/null | head -1 | cut -d= -f2); [ -n "$n" ] && v="$v($n)"; rc=$(grep -o 'rc=[0-9]*' $o/slang.log 2>/dev/null | tail -n 1)
    [ "$rc" != "rc=0" ] && v="$v[$rc]"
    m=$(md5sum < $o/ours.uhdm 2>/dev/null | cut -c1-8); [ -n "$prev" ] && [ "$m" = "$prev" ] && v="$v=" ; prev=$m
    line="$line	$v"; done; echo "$line"; }
export -f one; export BINS
printf '%s\n' "$@" | xargs -P3 -I{} bash -c 'one {}' | sort

#!/bin/bash
# v11u198: judge case dirs on the frozen pristine and law binaries ($VB/pris.bin, $VB/law.bin), one line per case:
#   <case> <pristine verdict> <law verdict> <SAME|MOVED>    (ELAB=1: the -elabuhdm form; JENV: extra env for the law run)
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
V() { awk '{ if ($1=="SLANG_FAIL"||$1=="SURELOG_FAIL") print $1; else if ($3=="STRICT_EQUAL") print "EQUAL"; else if ($3=="NOT_EQUAL") print "NOT_EQUAL"; else print $3":"$4 }'; }
one() { c=$1; k=$(echo "$c${ELAB:+E}" | md5sum | cut -c1-10); nm=$(echo $c | sed 's#.*/cases/##'); line="$nm"; ms=
  for b in pris ${LB:-law}; do o=/tmp/v11u198_judge/$b/$k; e=; [ $b != pris ] && e="$JENV"
    v=$(env $e SLANG_UHDM=$VB/$b.bin bash $HERE/case.sh $c $o 2>/dev/null | V)
    n=$(grep -o 'objects_differing=[0-9]*' $o/strict.txt 2>/dev/null | cut -d= -f2); [ -n "$n" ] && v="$v($n)"
    rc=$(grep -o 'rc=[0-9]*' $o/slang.log | tail -n 1); line="$line	$v[$rc]"; ms="$ms $(md5sum < $o/ours.uhdm 2>/dev/null | cut -c1-8)"; done
  set -- $ms; [ "$1" = "$2" ] && line="$line	SAME" || line="$line	MOVED"; echo "$line"; }
export -f one V; export HERE JENV ELAB LB
printf '%s\n' "$@" | xargs -P3 -I{} bash -c 'one {}' | sort

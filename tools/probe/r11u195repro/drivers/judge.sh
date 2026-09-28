#!/bin/bash
# r11u195: judge case dirs with frozen binaries: judge.sh "<bin names in $B>" <case dir>... -> one line per case:
# <case> <verdict per binary>(<objects differing>) and md5 equality marks.  Fence fail-closed through case.sh.
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
BINS=$1; shift
V() { awk '{ if ($1=="SLANG_FAIL"||$1=="SURELOG_FAIL") print $1; else if ($3=="STRICT_EQUAL") print "EQUAL"; else if ($3=="NOT_EQUAL") print "NOT_EQUAL"; else print $3":"$4 }'; }
one() { c=$1; k=$(echo "$c" | md5sum | cut -c1-10); line="$(echo $c | sed 's#.*/cases/##; s#.*/tools/probe/##; s#.*/tests/probe/##')"; prev=
  for b in $BINS; do o=/tmp/r11u195_judge/$b/$k; v=$(env $JENV SLANG_UHDM=$B/$b bash $HERE/case.sh $c $o 2>/dev/null | V)
    n=$(grep -o 'objects_differing=[0-9]*' $o/strict.txt 2>/dev/null | cut -d= -f2); [ -n "$n" ] && v="$v($n)"
    m=$(md5sum < $o/ours.uhdm 2>/dev/null | cut -c1-6); [ -n "$prev" ] && [ "$m" = "$prev" ] && v="$v=" ; prev=$m
    line="$line	$v"; done; echo "$line"; }
export -f one V; export HERE BINS JENV
printf '%s\n' "$@" | xargs -P3 -I{} bash -c 'one {}' | sort

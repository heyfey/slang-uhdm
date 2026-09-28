#!/bin/bash
# judge.sh "<label=ENV...:bin ...>" casedir...   each spec: label:binname[:ENVVAR=1,ENV2=1]
HERE=$(dirname "$(realpath "$0")")
. "$(dirname "$(realpath "$0")")"/env.sh || exit 3
SPECS=$1; shift
one() { c=$1; k=$(echo "$c" | md5sum | cut -c1-10); line="$(echo $c | sed 's#.*/cases/##')"; prev=
  for s in $SPECS; do lab=${s%%:*}; rest=${s#*:}; bin=${rest%%:*}; ev=; [ "$rest" != "$bin" ] && ev=$(echo ${rest#*:} | tr ',' ' ')
    o=/tmp/v11u195_judge/$lab/$k; r=$(env $ev SLANG_UHDM=$VB/$bin bash $HERE/case.sh $c $o 2>&1)
    v=$(echo "$r" | awk '{ if ($1=="SLANG_FAIL"||$1=="SURELOG_FAIL") print $1; else if ($4=="STRICT_EQUAL") print "EQUAL"; else if ($4=="NOT_EQUAL") print "NOT_EQUAL"; else print $4":"$5 }')
    cl=$(echo "$r" | grep -o 'cmplines=[0-9]*' | cut -d= -f2); rc=$(echo "$r" | grep -o 'rc=[0-9]*')
    n=$(grep -o 'objects_differing=[0-9]*' $o/strict.txt 2>/dev/null | cut -d= -f2); [ -n "$n" ] && v="$v($n)"
    m=$(md5sum < $o/ours.uhdm 2>/dev/null | cut -c1-6); [ -n "$prev" ] && [ "$m" = "$prev" ] && v="$v=" ; prev=$m
    line="$line	$lab:$v[c$cl,$rc]"; done; echo "$line"; }
export -f one; export SPECS HERE
printf '%s\n' "$@" | xargs -P3 -I{} bash -c 'one {}' | sort

#!/bin/bash
# grid.sh <list of case dirs> <out file> <tag>=<binary> [<tag>=<binary> ...]
# Every case in both views (EL=0/1) under every binary via case.sh, 3 cases at a time; one line per case-view-binary
# (case.sh's line: cmp=, cmplines=, strict=, rc=, md5=). Env assignments for a binary go through case.sh's own
# ENV=VAL arguments: write <tag>=<binary>:VAR=VAL,VAR=VAL. Fail-closed on $FENCED.
H="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; . "$H/env.sh" || exit 2
l=$1; out=$2; shift 2; specs="$*"
: > $out
grep -Ev "$FENCE_RE" $l | xargs -P 3 -I{} bash -c '
  for el in 0 1; do for sp in '"$specs"'; do
    t=${sp%%=*}; rest=${sp#*=}; b=${rest%%:*}; ev=""; [ "$rest" != "$b" ] && ev=$(echo ${rest#*:} | tr , " ")
    EL=$el bash '"$H"'/case.sh {} $t $b $ev
  done; done' >> $out 2>&1

#!/bin/bash
# v11u288 grid.sh <out> <case root> <tag=binary>...: every case dir x view d/e x binary, one line each
# with rc (case.sh's output); env pairs per tag via TAGENV_<tag>="VAR=1 ...". Fail-closed on $FENCED.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] || { echo "grid.sh: FENCED unset" >&2; exit 2; }
out=$1; root=$2; shift 2
H=$(dirname $(realpath $0))
: > $out
jobs_=()
for c in $(find $root -name dut.sv | sort | xargs -n1 dirname | grep -vwE "$(echo $FENCED | tr ' ' '|')"); do
  for v in d e; do
    for tb in "$@"; do
      tag=${tb%%=*}; bin=${tb#*=}; ev=TAGENV_$tag
      ( r=$(env ${!ev} bash $H/case.sh $c $bin $v); echo "${c#$root/} $v $tag $r" >> $out ) &
      while [ $(jobs -r | wc -l) -ge 3 ]; do sleep 0.2; done
    done
  done
done
wait
sort -o $out $out

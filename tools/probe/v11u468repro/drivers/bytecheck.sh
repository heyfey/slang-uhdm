#!/bin/bash
# bytecheck.sh <pristine> <law> <dirlist>: per case dir (absolute paths, one per line), exit code and bytes of
# both binaries (a FILES file lists the sources); prints "<dir> rc <p>/<l> same|MOVED".
A=$1; B=$2; L=$3
[ -x "$A" ] && [ -x "$B" ] || { echo "missing binary"; exit 1; }
one() {
  c=$1; W=/tmp/v11u468_bc$c; mkdir -p $W; rm -f $W/p.uhdm $W/l.uhdm
  F=dut.sv; [ -f $c/FILES ] && F=$(cat $c/FILES)
  (cd $c && timeout 120 "$A" $F --single-unit --nobuiltin -o $W/p.uhdm >/dev/null 2>&1 </dev/null); rp=$?
  (cd $c && timeout 120 "$B" $F --single-unit --nobuiltin -o $W/l.uhdm >/dev/null 2>&1 </dev/null); rl=$?
  m=same; cmp -s $W/p.uhdm $W/l.uhdm || m=MOVED
  echo "$c rc $rp/$rl $m"
}
export -f one; export A B
xargs -P 3 -I{} bash -c 'one {}' < "$L"

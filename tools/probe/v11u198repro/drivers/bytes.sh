#!/bin/bash
# v11u198: byte comparison of two binary runs over case dirs: bytes.sh "<binA> [ENV=..]" "<binB> [ENV=..]" <case>...
# prints SAME / MOVED per case (ELAB=1: the --elabuhdm form).  Fence fail-closed.
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
A=$1; B=$2; shift 2
one() { c=$1; D=$(cd $c && pwd); for f in $FENCED; do grep -qw "$f" <<< "$D" && exit 3; done
  SRC=dut.sv; [ -f "$D/args" ] && SRC=$(cat "$D/args"); o=/tmp/v11u198_bytes/$(echo "$D$ELAB" | md5sum | cut -c1-10); mkdir -p $o; ms=
  for spec in "$A" "$B"; do set -- $spec; bin=$1; shift; rm -f $o/x.uhdm; (cd $D && env "$@" $bin $SRC --single-unit --nobuiltin ${ELAB:+--elabuhdm} -o $o/x.uhdm >/dev/null 2>&1); ms="$ms $(md5sum < $o/x.uhdm 2>/dev/null | cut -c1-8)"; done
  set -- $ms; [ "$1" = "$2" ] && echo "SAME $c" || echo "MOVED $c"; }
export -f one; export A B ELAB FENCED
printf '%s\n' "$@" | xargs -P3 -I{} bash -c 'one {}' | sort -k2

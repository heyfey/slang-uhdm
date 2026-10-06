#!/bin/bash
# v11u268 ctlbytes.sh <outfile> <repro dir>...: byte controls, bytes first. Every case (dut.sv / dut.v dir) of
# the named tools/probe repro dirs, both views, on the frozen pristine, law and fix binaries ($B): one line per
# case-view: <case-view> rc=<p>,<l>,<f> md5=<p>,<l>,<f>. Movers are then judged with case.sh (verdicts, goldens).
# Paths are listed first and filtered by $FENCED (word boundary) before any case is opened; fail-closed.
[ -n "$FENCED" ] && [ "$(echo $FENCED | wc -w)" = 4 ] && [ -n "$B" ] && [ -n "$S" ] || { echo "ctlbytes.sh: source drivers/env.sh" >&2; exit 2; }
for t in pristine law fix; do [ -x "$B/$t" ] || { echo "ctlbytes.sh: $B/$t not executable" >&2; exit 2; }; done
H=$(cd "$(dirname "$0")/.." && pwd); out=$1; shift; : > $out
fre=$(echo $FENCED | tr ' ' '|')
one() {
  c=$1; el=$2; ox=; ek=; [ "$el" = 1 ] && { ox=--elabuhdm; ek=_el; }
  SRC=dut.sv; [ -f $c/dut.sv ] || SRC=dut.v; [ -f $c/args ] && SRC=$(cat $c/args)
  rel=$(echo $c | sed 's#.*/tools/probe/##')$ek; w=$S/ctl/$(echo $rel | tr '/' '_'); mkdir -p $w
  r=; m=
  for t in pristine law fix; do
    rm -f $w/$t.uhdm; (cd $c && timeout 300 $B/$t $SRC --single-unit --nobuiltin $ox -o $w/$t.uhdm > /dev/null 2>&1); rc=$?
    r="$r,$rc"; m="$m,$( [ -s $w/$t.uhdm ] && md5sum < $w/$t.uhdm | cut -c1-8 || echo none)"
  done
  # keep only movers' databases
  set -- $(echo ${m#,} | tr ',' ' '); [ "$1" = "$2" ] && [ "$2" = "$3" ] && rm -rf $w
  echo "$rel rc=${r#,} md5=${m#,}"
}
export -f one; export B S
for d in "$@"; do find $H/../$d \( -name dut.sv -o -name dut.v \) | sed 's#/dut\.s\?v$##'; done | sort -u | grep -vwE "$fre" |
  while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P ${CTLP:-3} -L 1 bash -c 'one $0 $1' >> $out

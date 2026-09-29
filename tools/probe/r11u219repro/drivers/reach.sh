#!/bin/bash
# r11u219: the switch-reach table (§ landingSwitchReach219). For every case dir (dut.sv, or an `args` file) under the
# given case trees, run $B/$LAWBIN in both views (EL=0 the parse form, EL=1 --elabuhdm) under each named switch state
# and print one line per case-view: <case-view> <state>=<md5-8> ...  States are given as NAME:VAR1,VAR2 (VAR set to 1);
# `base` = no switch.  Fail-closed on $FENCED (a path holding a fenced name is refused).
# usage: reach.sh "<state> <state> ..." <case tree>... > reach.tsv   (LAWBIN, S exported by the caller)
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
[ -n "$S" ] && [ -n "$LAWBIN" ] || { echo "reach.sh: export S and LAWBIN" >&2; exit 2; }
STATES=$1; shift
one() { c=$1; el=$2
  for n in $FENCED; do echo "$c" | grep -qw "$n" && { echo "$c FENCED refused"; return; }; done
  SRC=dut.sv; SV=; [ -f $c/dut.sv ] || SRC=dut.v; [ -f $c/args ] && SRC=$(cat $c/args)
  ox=; [ "$el" = 1 ] && ox=--elabuhdm
  rel=$(echo $c | sed 's#.*/tools/probe/##; s#.*/r11u219repro/#r11u219repro/#'); w=$S/reach/$rel$([ "$el" = 1 ] && echo _el); mkdir -p $w
  line="$rel$([ "$el" = 1 ] && echo _el)"
  for st in $STATES; do nm=${st%%:*}; vars=${st#*:}; envs=""
    [ "$vars" != "$nm" ] && [ -n "$vars" ] && envs=$(echo $vars | tr ',' '\n' | sed 's/$/=1/' | tr '\n' ' ')
    o=$w/$nm.uhdm; rm -f $o
    (cd $c && env $envs timeout 300 $B/$LAWBIN $SRC --single-unit --nobuiltin $ox -o $o > /dev/null 2>&1)
    line="$line $nm=$( [ -s $o ] && md5sum < $o | cut -c1-8 || echo NONE)"; rm -f $o
  done
  echo "$line"; }
export -f one; export HERE STATES
for t in "$@"; do find "$(realpath $t)" \( -name dut.sv -o -name dut.v -o -name args \) -printf '%h\n'; done | sort -u | while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P3 -L1 bash -c 'one $0 $1' | sort

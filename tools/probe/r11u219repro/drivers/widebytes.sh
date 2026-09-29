#!/bin/bash
# r11u219: the wide byte control. Every case dir (dut.sv, dut.v or an `args` file) under the given trees, both views
# (EL=0 the parse form, EL=1 --elabuhdm): the pristine binary $B/pristine and the law binary $B/$LAWBIN (with
# R11U214_TRACE / R11U219_TRACE into a per-case-view dir, so each line names the laws that fired); a byte mover is
# re-run under R11U219_OFF=1 and compared with the pristine bytes. One line per case-view:
#   <case-view> same|MOVED fired=<laws or -> [off=pristine|off=DIFF]
# Fail-closed on $FENCED (a path holding a fenced name is refused). usage: widebytes.sh <tree>... > wide.tsv
HERE=$(cd "$(dirname "$0")" && pwd); . "$HERE/env.sh" || exit 3
[ -n "$S" ] || { echo "widebytes.sh: export S" >&2; exit 2; }
export LAWBIN=${LAWBIN:-law}
one() { c=$1; el=$2
  for n in $FENCED; do echo "$c" | grep -qw "$n" && { echo "$c FENCED refused"; return; }; done
  SRC=dut.sv; [ -f $c/dut.sv ] || SRC=dut.v; [ -f $c/args ] && SRC=$(cat $c/args)
  ox=; [ "$el" = 1 ] && ox=--elabuhdm
  rel=$(echo $c | sed 's#.*/tools/probe/##')$([ "$el" = 1 ] && echo _el); w=$S/wide/$rel; rm -rf $w; mkdir -p $w/tr
  (cd $c && timeout 300 $B/pristine $SRC --single-unit --nobuiltin $ox -o $w/P.uhdm > /dev/null 2>&1); pr=$?
  (cd $c && R11U214_TRACE=$w/tr R11U219_TRACE=$w/tr timeout 300 $B/$LAWBIN $SRC --single-unit --nobuiltin $ox -o $w/L.uhdm > /dev/null 2>&1); lr=$?
  pm=$([ -s $w/P.uhdm ] && md5sum < $w/P.uhdm | cut -c1-12 || echo NONE); lm=$([ -s $w/L.uhdm ] && md5sum < $w/L.uhdm | cut -c1-12 || echo NONE)
  fired=$(cat $w/tr/* 2>/dev/null | grep -v '^OUT ' | awk '{print $1}' | sort | uniq -c | awk '{printf "%s:%s,", $2, $1}'); [ -z "$fired" ] && fired=-
  if [ "$pm" = "$lm" ] && [ $pr = $lr ]; then echo "$rel same fired=$fired rc=$pr"; rm -rf $w; return; fi
  (cd $c && R11U219_OFF=1 timeout 300 $B/$LAWBIN $SRC --single-unit --nobuiltin $ox -o $w/O.uhdm > /dev/null 2>&1)
  om=$([ -s $w/O.uhdm ] && md5sum < $w/O.uhdm | cut -c1-12 || echo NONE)
  echo "$rel MOVED fired=$fired rc=$pr/$lr off=$([ "$om" = "$pm" ] && echo pristine || echo DIFF)"; }
export -f one; export HERE
for t in "$@"; do find "$(realpath $t)" \( -name dut.sv -o -name dut.v -o -name args \) -printf '%h\n'; done | sort -u | while read c; do echo "$c 0"; echo "$c 1"; done | xargs -P3 -L1 bash -c 'one $0 $1'

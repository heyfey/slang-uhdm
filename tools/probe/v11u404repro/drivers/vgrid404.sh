#!/bin/bash
# vgrid404.sh <pristine binary> <law binary> <work dir> [case-glob] [verified binary]
# One line per case: pristine rc + verdict | law rc + verdict | R11U404_OFF rc and bytes vs pristine
# [| verified rc + verdict]. Verdict = uhdm-cmp exit (0 = equal) + uhdm-strictcmp's last line, both
# against the pinned Surelog's golden (-parse -sverilog, --top-module top when the case declares module top).
set -u
P=$1; L=$2; W=$3; G=${4:-*}; V=${5:-}
HERE=$(cd "$(dirname "$0")/.." && pwd); CASEROOT=${CASEROOT:-$HERE/cases}
: ${SURELOG:?} ${UHDM_CMP:?} ${STRICTCMP:?}
for t in "$P" "$L" "$UHDM_CMP" "$STRICTCMP" ${V:+"$V"}; do [ -x "$t" ] || { echo "missing tool $t"; exit 2; }; done
for d in $(cd $CASEROOT && ls -d $G/ | sort); do
  d=${d%/}; c=$CASEROOT/$d; w=$W/$d; mkdir -p $w
  T=""; grep -q '^module top\b' $c/dut.sv && T=top
  if [ ! -f $w/g/slpp_all/surelog.uhdm ]; then
    (cd $w && $SURELOG -parse -sverilog -nonote -noinfo -nowarning ${T:+--top-module $T} -mt 0 -mp 0 -o g $c/dut.sv > sl.log 2>&1; echo "surelog rc=$?" >> sl.log)
  fi
  verdict() { local o=$1; [ -f $o ] || { echo "nodb"; return; }; $UHDM_CMP $w/g/slpp_all/surelog.uhdm $o >/dev/null 2>&1; local r=$?; echo "cmp=$r $($STRICTCMP $w/g/slpp_all/surelog.uhdm $o 2>&1 | tail -1 | awk '{print $1, $2, $3}')"; }
  rm -f $w/p.uhdm $w/l.uhdm $w/o.uhdm $w/v.uhdm
  (cd $w && $P ${T:+--top $T} $c/dut.sv --single-unit -o $w/p.uhdm > p.log 2>&1); rp=$?
  (cd $w && $L ${T:+--top $T} $c/dut.sv --single-unit -o $w/l.uhdm > l.log 2>&1); rl=$?
  (cd $w && R11U404_OFF=1 $L ${T:+--top $T} $c/dut.sv --single-unit -o $w/o.uhdm > o.log 2>&1); ro=$?
  same=$(cmp -s $w/p.uhdm $w/o.uhdm && echo same || echo DIFF)
  lm=$(cmp -s $w/p.uhdm $w/l.uhdm && echo unmoved || echo moved)
  line="$d | sl $(tail -1 $w/sl.log) | pris rc=$rp $(verdict $w/p.uhdm) | law rc=$rl $lm $(verdict $w/l.uhdm) | off rc=$ro bytes=$same"
  if [ -n "$V" ]; then
    (cd $w && $V ${T:+--top $T} $c/dut.sv --single-unit -o $w/v.uhdm > v.log 2>&1); rv=$?
    line="$line | ver rc=$rv $(verdict $w/v.uhdm)"
  fi
  echo "$line"
done

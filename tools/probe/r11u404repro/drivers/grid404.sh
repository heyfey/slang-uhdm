#!/bin/bash
# grid404.sh <pristine binary> <law binary> <work dir> [case-glob]
# One line per case: case | pristine rc + verdict | law rc + verdict | R11U404_OFF rc and bytes vs pristine.
# The verdict is uhdm-cmp (0 = equal) then uhdm-strictcmp's last line, both against Surelog's golden
# (Surelog: -parse -sverilog, --top-module top when the case declares a module top; slang-uhdm the same top).
set -u
P=$1; L=$2; W=$3; G=${4:-*}
HERE=$(cd "$(dirname "$0")/.." && pwd)
SURELOG=${SURELOG:?}; UHDM_CMP=${UHDM_CMP:?}; SC=${STRICTCMP:-$(cd "$HERE/../../.." && pwd)/build/uhdm-strictcmp}
[ -x "$P" ] && [ -x "$L" ] && [ -x "$UHDM_CMP" ] || { echo "missing tool"; exit 2; }
for d in $(cd $HERE/cases && ls -d $G/*/ | sort); do
  d=${d%/}; c=$HERE/cases/$d; w=$W/$d; mkdir -p $w
  T=""; grep -q '^module top\b' $c/dut.sv && T=top
  if [ ! -f $w/g/slpp_all/surelog.uhdm ]; then
    (cd $w && $SURELOG -parse -sverilog -nonote -noinfo -nowarning ${T:+--top-module $T} -mt 0 -mp 0 -o g $c/dut.sv > sl.log 2>&1)
  fi
  verdict() { local o=$1; [ -f $o ] || { echo "nodb"; return; }; $UHDM_CMP $w/g/slpp_all/surelog.uhdm $o >/dev/null 2>&1; local r=$?; echo "cmp=$r $($SC $w/g/slpp_all/surelog.uhdm $o 2>&1 | tail -1 | awk '{print $1, $2}')"; }
  rm -f $w/p.uhdm $w/l.uhdm $w/o.uhdm
  (cd $w && $P ${T:+--top $T} $c/dut.sv --single-unit -o $w/p.uhdm > p.log 2>&1); rp=$?
  (cd $w && $L ${T:+--top $T} $c/dut.sv --single-unit -o $w/l.uhdm > l.log 2>&1); rl=$?
  (cd $w && R11U404_OFF=1 $L ${T:+--top $T} $c/dut.sv --single-unit -o $w/o.uhdm > o.log 2>&1); ro=$?
  same=$(cmp -s $w/p.uhdm $w/o.uhdm && echo same || echo DIFF)
  echo "$d | pris rc=$rp $(verdict $w/p.uhdm) | law rc=$rl $(verdict $w/l.uhdm) | off rc=$ro bytes=$same"
done

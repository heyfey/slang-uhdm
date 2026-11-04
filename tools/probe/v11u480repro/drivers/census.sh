#!/bin/bash
B=/home/heyfey/git-repos/slang-uhdm/tools/probe
O=/tmp/v11u480_cen
{ cat ${1:-/tmp/v11u480_census.txt} | sed "s#^\./#$B/#"; echo /tmp/wt_v11u480/tools/probe/r11u480repro/cases/FA/fa01; echo /tmp/wt_v11u480/tools/probe/r11u480repro/cases/FA/fa04; } | while read d; do
  [ -d "$d" ] || continue
  W=$O$d; mkdir -p $W; r=""
  for t in pris law; do rm -f $W/$t.uhdm; (cd $d && timeout 120 nice /tmp/v11u480_bin/slang-uhdm.$t dut.sv --single-unit --nobuiltin -o $W/$t.uhdm >/dev/null 2>&1 </dev/null); rc=$?; m=$( [ -f $W/$t.uhdm ] && md5sum < $W/$t.uhdm | cut -c1-8 || echo none); r="$r $rc $m"; done
  echo "$d$r"
done > /tmp/v11u480_census_out.txt
echo done >> /tmp/v11u480_census_out.txt

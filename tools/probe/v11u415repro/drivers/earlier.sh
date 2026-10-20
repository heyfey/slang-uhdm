#!/bin/bash
# v11u415 earlier.sh: every fence-filtered earlier-pass case dir: rc + md5 for pristine, law, ver
cd /tmp/wt_v11u415/tools/probe
O=/tmp/v11u415_scr/ep.uhdm
while read d; do
  TL=""; [ -f $d/TOP ] && TL="--top $(cat $d/TOP)"
  line="$d"
  for b in pristine law ${VER:-ver1}; do
    rm -f $O; (cd $d && timeout 120 /tmp/v11u415_bin/$b dut.sv $TL --single-unit --nobuiltin -o $O >/dev/null 2>&1); rc=$?
    m=$( [ -f $O ] && md5sum < $O | cut -c1-12 || echo none)
    line="$line $rc $m"
  done
  echo "$line"
done < /tmp/v11u415_scr/ed2.txt > ${OUT:-/tmp/v11u415_scr/earlier_res.txt}

#!/bin/bash
# switchcheck.sh <casedir>...: on the verified binary, each switch setting's md5 against
# the pristine (pris.uhdm) and law (law.uhdm) outputs grid3.sh left under /tmp/v11u463_runs.
V=/tmp/v11u463_bin/ver; [ -x "$V" ] || exit 1
for c in "$@"; do
  c=$(realpath "$c"); W=/tmp/v11u463_runs$c; line="${c#*/cases/}"
  for sw in R11U463_OFF R11U463_FIRSTLISTER_OFF R11V463_OFF R11V463_TDCHAIN_OFF R11V463_UNITGRP_OFF; do
    rm -f $W/sw.uhdm; (cd $c && env $sw=1 $V dut.sv --single-unit --nobuiltin -o $W/sw.uhdm >/dev/null 2>&1); rc=$?
    r=other; cmp -s $W/sw.uhdm $W/ver.uhdm && r=ver; cmp -s $W/sw.uhdm $W/law.uhdm && r="$r+law"; cmp -s $W/sw.uhdm $W/pris.uhdm && r="$r+pris"
    line="$line $sw:rc$rc=$r"
  done; echo "$line"
done

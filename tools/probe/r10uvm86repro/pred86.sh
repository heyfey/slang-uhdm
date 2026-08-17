#!/usr/bin/env bash
# r10uvm86 — THE MOVER PREDICTOR.  MEASUREMENT-ONLY, and it runs on PRISTINE
# databases: `ct86cen --list` over every slang.uhdm of a sweep workdir, printing
# the OHEAD sites this law's gate accepts (DIRECT + a package listing) BY NAME,
# so the mover set is stated BEFORE any patched build exists.
#
#   usage: pred86.sh <workdir_root> [ct86cen]
#
# The printed set is an UPPER BOUND: it also lists a DEFPKG site of the HOME
# package (which the law deliberately leaves alone — golden keeps its operation)
# and any EXPLICIT begin/end body, neither of which ct86cen can tell apart from
# the DB.  Both are named, never summarised, so the residual is read by hand.
set -u
WD=${1:?workdir root}
CEN=${2:-/tmp/r10uvm86_ct86cen}
[ -x "$CEN" ] || { echo "FATAL: no census tool at $CEN"; exit 3; }
n=0
find "$WD" -name slang.uhdm | sort | while read -r db; do
  rel=${db#"$WD"/}
  out=$("$CEN" "$db" --list 2>/dev/null)
  s=$(printf '%s\n' "$out" | grep -E '^DB' | sed 's/^DB\t[^\t]*\t//')
  d=$(printf '%s\n' "$out" | grep -F 'DIRECT' | grep -cE 'DEFPKG|TOPPKG'; true)
  [ "$d" = 0 ] && continue
  echo "== $rel  $s  pkg_DIRECT=$d"
  printf '%s\n' "$out" | grep -F 'DIRECT' | grep -E 'DEFPKG|TOPPKG' |
    awk -F'\t' '{print "   PRED "$6" "$7" @"$2}'
done

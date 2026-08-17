#!/usr/bin/env bash
# r10vrgg3/crashclass.sh — the CRASH CLASS r10rgg3 reported as its residue 3,
# characterised as a FAMILY rather than one input, and re-runnable as a gate for
# the § defPortsNullDefInstGuard fix.
#
#   usage: BASE=<binary> [FIX=<binary>] ./crashclass.sh
#
# THE DEFECT (pre-existing at 05d9c8f, present on the r10rgg3 binary too):
#   emitModuleDefPorts does `DefInfo& info = defMap[&def]`, which
#   DEFAULT-CONSTRUCTS, so `info.mod` is null for a definition never registered
#   with an instance object; emitImportArtifacts then dereferences it
#   (`m->Typespecs()`).  Any source holding an INTERFACE and NO TOP MODULE
#   reaches that state.  gdb on the base binary:
#     #0 emitImportArtifacts  #1 emitModuleDefPorts  #2 exportDesign
#
# GUARDS: a CRASH (rc >= 128) is reported distinctly from a plain rejection, and
# the golden side is taken for every shape so "we produce nothing" is never
# mistaken for "there is nothing to produce".
set -u
BASE=${BASE:?BASE=<binary>}
FIX=${FIX:-}
SL=${SURELOG:-$HOME/git-repos/Surelog/build/bin/surelog}
W=$(mktemp -d); cd "$W"
w(){ printf '%s' "$2" > "$1.sv"; }
w c1 'interface i1; parameter W=8; endinterface
'
w c2 'interface i1; logic [7:0] a; endinterface
'
w c3 'interface i1; endinterface
'
w c4 'package p; parameter W=8; endpackage
'
w c5 'program pr; parameter W=8; endprogram
'
w c6 'interface i1; parameter W=8; endinterface
module m; endmodule
'
w c7 'interface i1; parameter W=8; modport mp(input W); endinterface
'
w c8 'interface i1 #(parameter W=8); logic [W-1:0] a; endinterface
'
w c9 'interface i1; import p::*; parameter W=8; endinterface
package p; parameter Q=1; endpackage
'
w ca 'interface i1; parameter W=8; endinterface
interface i2; parameter V=9; endinterface
'
w cb 'checker ck; endchecker
'
w cc 'interface i1; typedef logic [7:0] t; parameter W=8; endinterface
'
w cd 'module m #(parameter W=8)(input logic [W-1:0] i); endmodule
'
w ce 'interface class ic; endclass
'
w cf 'interface i1; parameter W=8; endinterface
program pr; parameter V=9; endprogram
'
one(){ # $1=binary $2=file -> prints CRASH_rc / NODB_rc / OK_<bytes>
  rm -f o.uhdm
  "$1" --single-unit "$2" -o o.uhdm >/dev/null 2>&1
  local rc=$?
  if [ $rc -ge 128 ]; then echo "CRASH_$rc"
  elif [ -s o.uhdm ]; then echo "OK_$(stat -c %s o.uhdm)"
  else echo "NODB_$rc"; fi
}
crashes=0; fixed=0
printf "%-4s %-12s %-12s %s\n" FILE BASE FIX GOLDEN
for f in *.sv; do
  b=$(one "$BASE" "$f")
  x="-"; [ -n "$FIX" ] && x=$(one "$FIX" "$f")
  rm -rf slpp_all
  "$SL" -parse -nopython -d uhdm "$f" >/dev/null 2>&1
  g=$(stat -c %s slpp_all/surelog.uhdm 2>/dev/null || echo none)
  printf "%-4s %-12s %-12s %s\n" "${f%.sv}" "$b" "$x" "G=$g"
  case "$b" in CRASH_*) crashes=$((crashes+1));
    case "$x" in OK_*) fixed=$((fixed+1));; esac;; esac
done
cd /; rm -rf "$W"
echo "BASE CRASHES=$crashes   FIXED BY \$FIX=$fixed"
[ -n "$FIX" ] && { [ "$crashes" -eq "$fixed" ] || exit 5; }
exit 0

#!/usr/bin/env bash
# r10uvm70 — THE BOUNDARY CANARY the brief names by section.
#
#   usage: b68fence.sh <ctrl-bin> <final-bin>
#
# The brief fences `§ atomVarSignedWritten68` (EmitHelpers `clearNamedAtomSigned68`,
# 7 sites) and says its a1-a6 arms MUST hold.  This runs ALL SIX of that pass's
# own arm sources through BOTH binaries and compares OUR databases to each other
# — not to golden.  Golden cannot move between two of our builds, so the only
# question that matters is whether THE PATCH moved anything on 68's population,
# and a dump-vs-dump comparison answers it exactly.
#
# TRAP ENCODED, and it fired on the first run of this check: `uhdm-dump` prints
# `file:<abs path>` on every object that has one, and the two runs use DIFFERENT
# WORKDIRS, so a raw `cmp` reports EVERY arm as MOVED while the content is
# identical.  The workdir is normalised away before comparing.  A check that
# cannot tell a path from a payload is worse than no check: it cries wolf on a
# clean run and would be silenced next time.
#
# GUARDS: a missing arm source, a missing dump or an empty dump is fatal, so a
# check that measured nothing can never read as "identical".
set -u
CTL=${1:?control binary}
FIN=${2:?final binary}
A68=${A68:-$HOME/git-repos/slang-uhdm/tools/probe/r10uvm68repro}
[ -x "$CTL" ] && [ -x "$FIN" ] || { echo "FATAL: a binary is missing"; exit 3; }
[ -x "$A68/ct68arm.sh" ] || { echo "FATAL: no ct68arm.sh at $A68"; exit 3; }
echo "CTL=$(md5sum "$CTL" | cut -d' ' -f1)  FIN=$(md5sum "$FIN" | cut -d' ' -f1)"
moved=0; n=0
for a in a1_scope a2_atom a3_flavour a4_typaram a5_proto a6_tdarray; do
  [ -f "$A68/$a.sv" ] || { echo "FATAL: no arm $a.sv"; exit 3; }
  dc=/tmp/r10uvm70_b68ctl_$a; df=/tmp/r10uvm70_b68fin_$a
  (cd "$A68" && SLANG_UHDM=$CTL ./ct68arm.sh "$a.sv" "$dc" >/dev/null 2>&1)
  (cd "$A68" && SLANG_UHDM=$FIN ./ct68arm.sh "$a.sv" "$df" >/dev/null 2>&1)
  for f in "$dc/o.dump" "$df/o.dump"; do
    [ -s "$f" ] || { echo "FATAL: missing/empty $f"; exit 6; }
  done
  sed "s#$dc#WD#g" "$dc/o.dump" > /tmp/r10uvm70_b68n_c.dump
  sed "s#$df#WD#g" "$df/o.dump" > /tmp/r10uvm70_b68n_f.dump
  n=$((n+1))
  if cmp -s /tmp/r10uvm70_b68n_c.dump /tmp/r10uvm70_b68n_f.dump; then
    echo "  $a: OURS-DUMP-IDENTICAL (68's arm untouched)"
  else
    echo "  $a: OURS-DUMP-MOVED  sides=$(diff /tmp/r10uvm70_b68n_c.dump \
         /tmp/r10uvm70_b68n_f.dump | grep -cE '^[<>]')"
    diff /tmp/r10uvm70_b68n_c.dump /tmp/r10uvm70_b68n_f.dump | head -10
    moved=$((moved+1))
  fi
done
rm -f /tmp/r10uvm70_b68n_c.dump /tmp/r10uvm70_b68n_f.dump
echo "---- arms=$n  MOVED=$moved"
[ "$n" -eq 6 ] || { echo "REFUSING TO REPORT: expected 6 arms"; exit 4; }
[ "$moved" -eq 0 ] && echo "PASS: § atomVarSignedWritten68's a1-a6 all byte-identical." || exit 5

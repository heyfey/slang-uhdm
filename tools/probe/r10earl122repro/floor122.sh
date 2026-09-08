#!/usr/bin/env bash
# r10earl122 — THE MUST-STAY FLOOR, checked BY NAME against the boundary's
# differing list.  A floor arm in the list is a REGRESSION, not a note.
set -u
DIFF=${1:?boundary .diff file}
FLOOR="r10earl121repro r10vearl121repro r10earl120repro r10earl119repro
r10earl118repro r10earl117repro r10earl116repro r10earl115repro r10earl114repro
r10earl113repro r10earl112repro r10earl111repro r10earl110repro r10earl106repro
r10uvm82repro r10uvm83repro r10uvm84repro r10uvm85repro r10uvm86repro
r10uvm87repro r10uvm88repro r10uvm89repro r10uvm90repro r10uvm91repro
r10buvm3repro r10buvm4repro r10buvm5repro r10buvm6repro r10buvm7repro
r10buvm8repro r10buvm9repro r10buvm10repro r10buvm11repro r10buvm12repro
r10buvm13repro r10buvm14repro r10buvm15repro
r10sd8repro r10sd9repro r10sd10repro r10sd11repro r10sd12repro"
bad=0; n=0
for d in $FLOOR; do
  n=$((n+1))
  if grep -q "$d/" "$DIFF"; then echo "FLOOR-BREACH: $d appears in the differing list"; bad=1; fi
done
echo "floor dirs checked=$n  BREACHES=$bad"
[ "$bad" = 0 ] && echo "PASS: no must-stay arm moved" || exit 5

#!/bin/bash
# gridall.sh <pristine-bin> <law-bin>: every case under ../cases with four runs — pristine, law,
# law with R11U155_OFF=1 and law with the case's own switch(es) (named by its first line) — then
# byte identity of the OFF and own-switch databases against pristine.
# prints: <case> | pristine verdict | law verdict | OFF verdict + bytes | own-switch verdict + bytes
P=$1; L=$2; D=$(dirname $(realpath $0)); C=$(dirname $D)/cases
sw() { case "$1" in
  initTsEndProgramLocal155) echo R11U155_PRGINITEND_OFF=1;;
  implicitArgDimsInner155) echo R11U155_IMPLARGDIM_OFF=1;;
  nonAnsiArrayNetAtHeader155) echo R11U155_NAARRNET_OFF=1;;
  unitAggTfArgLastWriter155) echo R11U155_UNITUNIONARG_OFF=1 R11U155_UNITSTRUCTARG_OFF=1;;
  pselConnNameNotFrozen155) echo R11U155_PSELNAME_OFF=1;;
  packedStructNdaFoldConstLoc155) echo R11U155_NDAFOLDLOC_OFF=1;;
  ifacePortViewFoldAtLeftOperand155) echo R11U155_PVLEFTOP_OFF=1;;
  pkgTdStretchNonAnsiHeaderSkips155) echo R11U155_TDSTRETCHHDR_OFF=1;;
  modAggTfArgLastWriter155) echo R11U155_MODAGGARG_OFF=1;;
  dirlessFormalTypeAtName155) echo R11U155_DIRLESSNAME_OFF=1;;
  ifaceSigConnNamedByChildPort155) echo R11U155_IFSIGCHILD_OFF=1;;
  *) echo NONE=1;; esac; }
GW=${GW:-/tmp/r11u155_g}
for c in $(ls -d $C/*/*/ | sort); do
  rel=$(echo $c | sed "s#.*/cases/##; s#/\$##")
  law=$(head -1 $c/dut.sv | grep -o '§ [A-Za-z0-9]*' | cut -c3-)
  v() { echo "$1" | sed 's/.*strict=//; s/ rc=.*//'; }
  a=$($D/grid.sh $c $P pris); b=$($D/grid.sh $c $L law); o=$($D/grid.sh $c $L off R11U155_OFF=1)
  s=$($D/grid.sh $c $L own $(sw "$law"))
  cmp -s $GW/$rel/pris.uhdm $GW/$rel/off.uhdm && ob=SAME || ob=DIFF
  cmp -s $GW/$rel/pris.uhdm $GW/$rel/own.uhdm && sb=SAME || sb=DIFF
  echo "$rel | ${law:-residue} | $(v "$a") | $(v "$b") cmp=$(echo $b | grep -o 'cmplines=[0-9]*') | off $(v "$o") bytes=$ob | own $(v "$s") bytes=$sb"
done

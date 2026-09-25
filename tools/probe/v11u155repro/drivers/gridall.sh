#!/bin/bash
# gridall.sh: every case under ../cases with the pristine (P), implementer law (L), verified (V) binaries,
# V under R11U155_OFF=1 (O), and V under the case's own switch (S; set per law below). Needs the frozen binaries.
D=$(dirname $(realpath $0)); C=$D/../cases; B=/tmp/v11u155_bin
sw() { case $(head -1 $1/dut.sv | awk '{print $3}') in
  ifaceSigConnNamedByChildPort155) echo R11U155_IFSIGCHILD_OFF;; ifacePortViewFoldAtLeftOperand155) echo R11U155_PVLEFTOP_OFF;;
  dirlessFormalTypeAtName155) echo R11U155_DIRLESSNAME_OFF;; implicitArgDimsInner155) echo R11U155_IMPLARGDIM_OFF;;
  modAggTfArgLastWriter155) echo R11U155_MODAGGARG_OFF;; unitAggTfArgLastWriter155) echo "R11U155_UNITUNIONARG_OFF=1 R11U155_UNITSTRUCTARG_OFF";;
  initTsEndProgramLocal155) echo R11U155_PRGINITEND_OFF;; packedStructNdaFoldConstLoc155) echo R11U155_NDAFOLDLOC_OFF;;
  pselConnNameNotFrozen155) echo R11U155_PSELNAME_OFF;; nonAnsiArrayNetAtHeader155) echo R11U155_NAARRNET_OFF;;
  naArrNetOwnPortDecl155v) echo R11V155_NAARRSEP_OFF;; pkgTdStretchNonAnsiHeaderSkips155) echo R11U155_TDSTRETCHHDR_OFF;;
  tdStretchProgramKeeps155v) echo R11V155_TDPRG_OFF;; esac; }
for c in $(ls -d $C/*/*/ | sort); do
  $D/grid.sh $c gold x
  $D/grid.sh $c $B/pris.bin P; $D/grid.sh $c $B/law.bin L; $D/grid.sh $c $B/ver.bin V
  $D/grid.sh $c $B/ver.bin O R11U155_OFF=1; $D/grid.sh $c $B/ver.bin S $(sw $c | sed 's/\([A-Z0-9_]*\)$/\1=1/')
done

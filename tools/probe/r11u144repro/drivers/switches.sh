#!/bin/bash
# switches.sh <law binary> <evidence dir>: every switch alone; per cell: moved (vs law) and back-to-pristine
D=$(cd "$(dirname "$0")" && pwd); bin=$1; E=$2
for sw in R11U144_SELBAREDEC_OFF R11U144_CALLBITSEL_OFF R11U144_FOLDTSNAME_OFF R11U144_ELABINST_OFF R11U144_ELABPROP_OFF R11U144_TPPACKEDNET_OFF R11U144_PARAMALIASREF_OFF R11U144_PKGQUALREF_OFF R11U144_METHQUALSPAN_OFF R11U144_METHATTR_OFF R11U144_DEFGENHP_OFF; do
  bash $D/grid.sh $bin S $sw=1 > $E/grid_sw_$sw.txt 2>&1
  moved=$(paste -d' ' <(awk '{print $1, $NF}' $E/grid_law.txt) <(awk '{print $NF}' $E/grid_sw_$sw.txt) | awk '$2!=$3{print $1}' | tr '\n' ' ')
  nonpris=$(paste -d' ' <(awk '{print $1, $NF}' $E/grid_pristine.txt) <(awk '{print $NF}' $E/grid_sw_$sw.txt) <(awk '{print $NF}' $E/grid_law.txt) | awk '$4!=$3 && $2!=$3{print $1}' | tr '\n' ' ')
  echo "$sw moved: $moved | moved-but-not-pristine: $nonpris"
done

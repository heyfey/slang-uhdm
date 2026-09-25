#!/bin/bash
# gridall.sh [dir...]: every case of the named case dirs (default: all) under four
# binaries/switch states: pristine (P), law (L), law with R11U160_OFF=1 (OFF), law
# with the dir's own switches (SW).  Prints the verdicts and whether OFF / SW
# are byte-identical to P (the database, as written by slang-uhdm -o).
# Needs PRIS / LAW (absolute binaries); scratch under GW (default /tmp/r11u160_g).
D=$(cd "$(dirname "$0")" && pwd); C=$(dirname $D)/cases
PRIS=${PRIS:-/tmp/r11u160_bin/pris.bin}; LAW=${LAW:-/tmp/r11u160_bin/law.bin}
GW=${GW:-/tmp/r11u160_g}; export GW
sw() { case $1 in
  MA) echo R11U160_OBJMACROPAREN_OFF=1;;
  GT) echo R11U160_TPWHOLELHS_OFF=1;;
  TP) echo R11U160_TPUSEUNIT_OFF=1 R11U160_TPUSEDEF_OFF=1;;
  TV) echo R11U160_TPPACKEDVEC_OFF=1 R11U160_TPUSEDEF_OFF=1;;
  BT) echo R11U160_BODYTPDEF_OFF=1 R11U160_TPUSEDEF_OFF=1;;
  MM) echo R11U160_PPINACTIVE_OFF=1 R11U160_PPARGNL_OFF=1 R11U160_PPBUILTIN_OFF=1 R11U160_PPSTRINGIFY_OFF=1 R11U160_PPPASTE_OFF=1 R11U160_PPNESTCOL_OFF=1 R11U160_PPPUSHLINE_OFF=1;;
  CP) echo R11U160_IMPLBAREPARAM_OFF=1;;
  S7) echo R11U160_CATCH_OFF=1;;
esac; }
dirs=("$@"); [ ${#dirs[@]} = 0 ] && dirs=($(ls $C))
for d in "${dirs[@]}"; do for c in $(ls $C/$d); do
  cd=$C/$d/$c; w=$GW/$d/$c
  p=$($D/grid.sh $cd $PRIS P | awk '{print $3,$4,$5,$6}')
  l=$($D/grid.sh $cd $LAW L | awk '{print $3,$4,$5,$6}')
  $D/grid.sh $cd $LAW OFF R11U160_OFF=1 >/dev/null
  $D/grid.sh $cd $LAW SW $(sw $d) >/dev/null
  bo=$(cmp -s $w/P.uhdm $w/OFF.uhdm && echo same || echo DIFF)
  bs=$(cmp -s $w/P.uhdm $w/SW.uhdm && echo same || echo DIFF)
  [ -s $w/P.uhdm ] || { bo=nodb; bs=nodb; }
  echo "$d/$c | P: $p | L: $l | OFF-bytes:$bo | SW-bytes:$bs"
done; done

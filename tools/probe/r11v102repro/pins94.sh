#!/bin/bash
# r11v102 protected-database pins + the seven conversion rows, from one sweep workdir.
# usage: pins94.sh <sweep workdir (holds sl/ and sl.csv)>
W=${1:?sweep workdir}
for n in SVSwitch YosysVerx InterfaceModPort BlackParrotComplex YosysOldOr Earlgrey_0_1; do
  for m in default testflags; do
    f=$(ls -d $W/sl/$m/$n-*/slang.uhdm 2>/dev/null | head -1)
    printf "%s/%s=%s " $n $m "$( [ -n "$f" ] && md5sum $f | cut -c1-12 || echo NOFILE)"
  done
done; echo
for n in BuildUVMPkg MiniAmiq SeqDriver SimpleUVM Scoreboard Earlgrey_0_1 ParamOverloading; do grep "^$n," $W/sl.csv | cut -d, -f1-3 | tr '\n' ' '; done; echo

#!/bin/bash
# det3.sh <row workdir with cmds.txt> <source dir the sweep ran in> <tag>: three
# concurrent runs of the row's slang command line from the sweep's cwd, md5 of each
# next to the sweep's database (only the -o path differs)
d=$1; src=$2; t=$3
C=$(grep '^slang:' $d/cmds.txt | sed 's/^slang: *//; s| -o .*$||')
cd $src
for i in 1 2 3; do rm -f /tmp/v11u450_det_${t}$i.uhdm; eval "$C -o /tmp/v11u450_det_${t}$i.uhdm" >/dev/null 2>&1 & done
wait
md5sum /tmp/v11u450_det_${t}?.uhdm $d/slang.uhdm | cut -c1-12

#!/bin/bash
# dsgrid.sh <binary tag: pristine|law|ver3> <casedir>...: downstream verdict per case (ds.one, downstream flags), class-free cases only
B=/tmp/v11u444_bin/$1; shift; [ -x "$B" ] || { echo "no binary"; exit 2; }
source /tmp/v11u444_scr/env.sh; export SLANG_UHDM=$B
W=/tmp/v11u444_scr/ds_$(basename $B); mkdir -p $W
for c in "$@"; do
  c=$(cd $c && pwd); grep -q '\bclass\b' $c/dut.sv && { echo "$(basename $(dirname $c))/$(basename $c) SKIP-class"; continue; }
  n=$(basename $(dirname $c))_$(basename $c)
  tp=; [ -f $c/TOP ] && tp=",'-top','$(cat $c/TOP)'"
  r=$(cd /home/heyfey/git-repos/slang-uhdm && python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; print(ds.one('$n', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'$tp], '$W', 300))" 2>&1 | tail -1)
  echo "$(basename $(dirname $c))/$(basename $c) $r"
done

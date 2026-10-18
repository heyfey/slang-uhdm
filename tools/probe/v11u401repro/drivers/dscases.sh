#!/bin/bash
# v11u401 downstream verdict of every module-only case for one binary: ds.sh <bin> <out>
export SURELOG_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/Surelog UHDM2RTLIL_TESTS=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil/test SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog UHDM_CMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-cmp UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil
export SLANG_UHDM=$1; O=$2; W=/tmp/v11u401_dsw$(basename $1 | tr -cd 'a-z0-9' | tail -c 4); mkdir -p $W
C=/tmp/wt_v11u401/tools/probe/v11u401repro/cases
cd /tmp/wt_v11u401
for d in $(cd $C && ls -d */*/ | sed 's#/$##'); do
  grep -q '\bclass\b' $C/$d/dut.sv && continue
  r=$(python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$(echo $d | tr / _)', '$C/$d', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '$W', 300); print(r)" 2>&1 | tail -1)
  echo "$d $r"
done > $O

#!/bin/bash
# dsgrid.sh <binary> <tag> <casedir>...: downstream verdict per case (scripts/downstream_uhdm2rtlil.py one())
B=$1; T=$2; shift 2
[ -x "$B" ] || { echo "missing binary"; exit 2; }
export SLANG_UHDM=$B UHDM2RTLIL_ROOT=/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog
cd /home/heyfey/git-repos/slang-uhdm
for c in "$@"; do
  c=$(cd $c && pwd); k=$(echo $c | sed "s|.*/cases/||; s|/|_|g")
  v=$(python3 -c "import sys; sys.path.insert(0,'scripts'); import downstream_uhdm2rtlil as ds; r=ds.one('$k', '$c', ['-parse','-nobuiltin','-nocache','-sv','dut.sv'], '/tmp/v11u431_dsw/$T', 300); print(r['verdict'], r.get('differs',''))" 2>&1 | tail -1)
  echo "$k $v"
done

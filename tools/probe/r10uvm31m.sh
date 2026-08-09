#!/bin/bash
# r10uvm31m.sh <sweep-workdir> — pass 31's io_decl TYPESPEC metric, and the one
# to carry forward.  `r10uvm30iom.sh` reports IOTOTAL2 as a raw
# `diff | grep -c '^[<>]'`, which counts one wrong formal TWICE and gives no
# shape at all; this one joins the two censuses by ROW KEY and reports the
# residue by PAIR CLASS (ts/KIND, ts/NAME, ts/INST), which is what ranked the
# work this pass and what should rank the next.
#
#   R10IO=<r10uvm30io or r10uvm31io build> tools/probe/r10uvm31m.sh /tmp/xw
#
# IOTOTAL2 stays comparable across passes (run r10uvm30iom.sh for it);
# PAIRTOTAL below is the same residue counted ONCE per formal.
set -u
SW=${1:?sweep workdir}
V=${R10IO:?set R10IO to an r10uvm30io build}
HERE=$(cd "$(dirname "$0")" && pwd)
TOT=0
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d "$SW"/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir"; continue; }
  G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
  [ -f "$G" ] || { echo "$T: no golden"; continue; }
  "$V" "$G"            > /tmp/r10uvm31m.g.$$
  "$V" "$D/slang.uhdm" > /tmp/r10uvm31m.o.$$
  N=$(python3 "$HERE/r10uvm31pair.py" /tmp/r10uvm31m.g.$$ /tmp/r10uvm31m.o.$$ \
        --top 0 | sed -n 's/^PAIRTOTAL=//p')
  echo "$T pairs=$N"
  TOT=$((TOT+N))
done
rm -f /tmp/r10uvm31m.g.$$ /tmp/r10uvm31m.o.$$
echo "PAIRTOTAL=$TOT"

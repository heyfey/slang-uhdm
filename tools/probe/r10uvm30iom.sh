#!/bin/bash
# r10uvm30iom.sh <sweep-workdir> — pass 30's io_decl FORMAL metric, and the
# one to carry forward: r10uvm29iom projected only the KIND and NAME of a
# formal's default, so a value-only pair (`REAL:1.5` vs `REAL:1.500000`, the
# § classPropRealInitRawValue29 shape) was invisible to it, and it printed
# nothing at all for a method whose io_decl vector we drop entirely (the
# 107-row pure-virtual deficit § pureVirtIoDecls30 closed).  This one uses
# r10uvm30io: every class method in every view, `io[-] <none>` for an empty
# vector, and per formal the direction, the ACTUAL typespec (kind/name/
# vpiInstance) and the default's kind/name/value/decompile.
#
#   R10IO=<r10uvm30io build> tools/probe/r10uvm30iom.sh /tmp/xw
set -u
SW=${1:?sweep workdir}
V=${R10IO:?set R10IO to an r10uvm30io build}
TOT=0
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d "$SW"/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir"; continue; }
  G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
  [ -f "$G" ] || { echo "$T: no golden"; continue; }
  "$V" "$G"            > /tmp/r10uvm30iom.g.$$
  "$V" "$D/slang.uhdm" > /tmp/r10uvm30iom.o.$$
  N=$(diff /tmp/r10uvm30iom.g.$$ /tmp/r10uvm30iom.o.$$ | grep -c '^[<>]')
  echo "$T iodiff=$N (golden rows $(wc -l < /tmp/r10uvm30iom.g.$$), ours $(wc -l < /tmp/r10uvm30iom.o.$$))"
  TOT=$((TOT+N))
done
rm -f /tmp/r10uvm30iom.g.$$ /tmp/r10uvm30iom.o.$$
echo "IOTOTAL2=$TOT"

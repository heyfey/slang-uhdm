#!/bin/bash
# r10uvm27m.sh <sweep-workdir> — THE CONSTRUCTOR-BODY metric for the UVM-4: the
# r10uvm27s task_func body-SHAPE census (Stmt kind, and for a begin the ordered
# kinds+names of its Stmts, per package/class view), golden vs ours.  Split into
# the constructor rows (`::new`) that § constructorBodyElementShift27 and
# § ctorDeclIsRhslessAssignment27 own, and the rest of the body residue.
#
#   R10S=<r10uvm27s build> tools/probe/r10uvm27m.sh /tmp/xw
set -u
SW=${1:?sweep workdir}
V=${R10S:?set R10S to an r10uvm27s build}
CT=0
OT=0
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d "$SW"/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir"; continue; }
  G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
  "$V" "$G" > /tmp/r10uvm27m_g.txt 2>/dev/null
  "$V" "$D/slang.uhdm" > /tmp/r10uvm27m_o.txt 2>/dev/null
  c=$(diff /tmp/r10uvm27m_g.txt /tmp/r10uvm27m_o.txt | grep '^<' | grep -c '::new ')
  a=$(diff /tmp/r10uvm27m_g.txt /tmp/r10uvm27m_o.txt | grep -c '^<')
  echo "$T ctor=$c other=$((a - c))"
  CT=$((CT + c)); OT=$((OT + a - c))
done
echo "CTORTOTAL=$CT BODYOTHER=$OT"

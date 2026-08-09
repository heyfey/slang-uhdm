#!/bin/bash
# r10uvm29iom.sh <sweep-workdir> — the FORMAL-DEFAULT metric for the UVM-4:
# the r10uvm29io census (every class method's io_decls with the KIND and NAME
# of their vpiExpr default), golden vs ours.  This became the design head the
# moment § classPropInit29 cleared the class_var initializers: golden drops a
# formal default that names an ENUM CONSTANT (`uvm_radix_enum radix =
# UVM_NORADIX`) where we keep a ref_obj, and its io_decl LISTINGS are longer
# than ours besides.
#
#   R10IO=<r10uvm29io build> tools/probe/r10uvm29iom.sh /tmp/xw
set -u
SW=${1:?sweep workdir}
V=${R10IO:?set R10IO to an r10uvm29io build}
TOT=0
for T in BuildUVMPkg Scoreboard SeqDriver SimpleUVM; do
  D=$(ls -d "$SW"/default/$T-* 2>/dev/null | head -1)
  [ -n "$D" ] || { echo "$T: no workdir"; continue; }
  G=$(grep -o "$HOME/.cache/slang-uhdm-goldens/[0-9a-f]*" "$D/cmds.txt" | head -1)/golden.uhdm
  [ -f "$G" ] || { echo "$T: no golden"; continue; }
  "$V" "$G"            > /tmp/r10uvm29iom.g.$$
  "$V" "$D/slang.uhdm" > /tmp/r10uvm29iom.o.$$
  N=$(diff /tmp/r10uvm29iom.g.$$ /tmp/r10uvm29iom.o.$$ | grep -c '^[<>]')
  echo "$T iodiff=$N (golden rows $(wc -l < /tmp/r10uvm29iom.g.$$), ours $(wc -l < /tmp/r10uvm29iom.o.$$))"
  TOT=$((TOT+N))
done
rm -f /tmp/r10uvm29iom.g.$$ /tmp/r10uvm29iom.o.$$
echo "IOTOTAL=$TOT"

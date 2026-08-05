#!/bin/bash
# r10uvm21ab.sh <srcTestDir> <tag> [editCmd] -- copy a uvm-1.2 test's sources to
# /tmp/r10uvm21_ab/<tag>, optionally EDIT them ($0 is the copy's directory), run
# Surelog with the harness's DEFAULT-mode argv, and histogram the foreach
# loop-variable kinds per view with r10uvm21_20a (a build of r10uvm20a.cpp).
#
# This is the A/B that decoded § classPropUnitImport21: the same sources, the
# same command line, ONE line of difference.
#
#   R10P=/tmp/r10uvm21_20a tools/probe/r10uvm21ab.sh \
#     ~/git-repos/Surelog/third_party/tests/SeqDriver seq_base
#   R10P=/tmp/r10uvm21_20a tools/probe/r10uvm21ab.sh \
#     ~/git-repos/Surelog/third_party/tests/SeqDriver seq_unitimp \
#     'sed -i "1i import uvm_pkg::*;" $0/design.sv'
#
# NOTE the argv below is the `default` mode one for the three uvm-1.2 tests
# (SeqDriver, SimpleUVM, Scoreboard).  Read it back off a sweep workdir's
# cmds.txt if the harness's translation table ever changes.
set -u
SL=${R10SL:-$HOME/git-repos/Surelog/build/bin/surelog}
P=${R10P:-/tmp/r10uvm21_20a}
UVM=$HOME/git-repos/Surelog/third_party/UVM/uvm-1.2/src
SRC=$1; DST=/tmp/r10uvm21_ab/$2
rm -rf "$DST"; mkdir -p "$DST"
cp "$SRC"/design.sv "$SRC"/testbench.sv "$DST"/ 2>/dev/null
shift 2
[ $# -gt 0 ] && bash -c "$1" "$DST"
cd "$DST" || exit 1
$SL -parse -noprecompiledcache "+incdir+.+$UVM/" ${EXTRA:-} -sverilog \
    "$UVM/uvm_pkg.sv" design.sv testbench.sv -mt 0 -mp 0 -o "$DST/w" \
    > sl.log 2>&1
U=$(ls "$DST"/w/slpp_all/*.uhdm 2>/dev/null | head -1)
echo "uhdm=$U"
[ -n "$U" ] || exit 1
$P "$U" 2>/dev/null | awk '{
  for (i=1;i<=NF;i++) if ($i=="lv") { k=$(i+2); break }
  v=$1; sub(/\/.*/,"",v); sub(/\[.*/,"",v); c[v" "k]++
} END { for (x in c) printf "%6d %s\n", c[x], x }' | sort -k2,2 -k3,3

#!/bin/bash
# r11u222map: pin the writer of a symbol-table ordering coin. Runs the -g1 build ($B/slang-uhdm.g1) under gdb on one
# corpus row-mode with the HEAD sweep's command line and cwd, breaks on UHDM::SymbolFactory::Make (and ::add) when the interned
# string equals $SYM (a condition on the string_view registers: SymbolId is returned through a hidden pointer, so rdi = the result, rsi = this, rdx = length, rcx = data), and prints the
# backtrace of the first hit.   usage: pinsym.sh <test> <mode> <symbol> <out prefix>
. "$(dirname "$0")/env.sh"
t=$1; m=$2; SYM=$3; O=$4
echo "$t" | grep -Pq "$FENCERE" && { echo "FENCED refused"; exit 3; }
d=$(ls -d $H/surelog/$m/$t-* | head -1)
args=$(grep '^slang:' $d/cmds.txt | sed 's/^slang:\s*//; s#^\S*slang-uhdm ##; s# -o \S*$##')
cwd=$(cd $REPO && python3 -c "import sys; sys.path.insert(0,'scripts'); import verify_golden as vg; print(vg.discover_surelog(None)['$t'][0])")
n=${#SYM}
cat > $O.gdb <<GDB
set pagination off
set breakpoint pending on
break UHDM::SymbolFactory::Make if \$rdx == $n && \$_memeq(\$rcx, "$SYM", $n)
break UHDM::SymbolFactory::add if \$rdx == $n && \$_memeq(\$rcx, "$SYM", $n)
run
bt 14
info registers rdx rcx
kill
quit
GDB
rm -f $O.uhdm
(cd $cwd && eval "timeout 3600 gdb -q -batch -x $O.gdb --args $B/slang-uhdm.g1 $args -o $O.uhdm") > $O.txt 2>&1
grep -E '^#[0-9]+' $O.txt | head -14

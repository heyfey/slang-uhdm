#!/usr/bin/env bash
# fpspans.sh <arm dir> <out dir>: builds the arm with uhdm2rtlil's own Surelog
# under the downstream flags WITH and WITHOUT -filterprotected and prints the
# multiset of (type span) rows of the located objects that differ — the
# filler-line shift map of -filterprotected, measured on the producer itself.
set -u
A=$(cd "$1" && pwd); O=$2
U2RSL=${UHDM2RTLIL_ROOT:-/home/heyfey/git-repos/slang-uhdm/third_party/uhdm2rtlil}/build/third_party/Surelog/bin/surelog
IDL=${IDL:-/tmp/r11u120_idlist}
rm -rf "$O"; mkdir -p "$O"/fp "$O"/nofp
(cd "$A" && $U2RSL -parse -nobuiltin -nocache -DSYNTHESIS -filterprotected -d vpi_ids -d uhdm -sv dut.sv -mt 0 -mp 0 -o "$O"/fp >"$O"/fp.log 2>&1); r1=$?
(cd "$A" && $U2RSL -parse -nobuiltin -nocache -DSYNTHESIS -d vpi_ids -d uhdm -sv dut.sv -mt 0 -mp 0 -o "$O"/nofp >"$O"/nofp.log 2>&1); r2=$?
f() { $IDL "$(find "$1" -name surelog.uhdm | head -1)" '^(cont_assign|module_inst|initial|port|ref_obj|constant)$' | awk '{print $4, $5, $6}' | sort | uniq; }
f "$O"/fp > "$O"/fp.txt; f "$O"/nofp > "$O"/nofp.txt
echo "ARM $(basename $A) rc=$r1/$r2"
diff "$O"/nofp.txt "$O"/fp.txt | grep '^[<>]' | grep -E 'cont_assign|module_inst|initial' 

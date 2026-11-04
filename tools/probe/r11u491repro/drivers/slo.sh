#!/bin/bash
# slo.sh <outdir>: "default|actual|body" -> Surelog A param_assign rhs + parent kind
SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog; UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$SURELOG" ] && [ -x "$UHDM_DUMP" ] || exit 1
O=$1; mkdir -p $O; i=0
while IFS='|' read -r df act body; do i=$((i+1)); d=$O/c$i; mkdir -p $d
 [ -z "$body" ] && body="assign o = A;"
 printf '%s\n' "module m #(parameter A = $df) (output logic [7:0] o); $body endmodule" "module top; logic [7:0] o; m #(.A($act)) u(o); endmodule" > $d/dut.sv
 [ -f $d/sl.dump ] || { (cd $d && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $d/sl >$d/sl.log 2>&1); $UHDM_DUMP $d/sl/slpp_all/surelog.uhdm 2>/dev/null > $d/sl.dump; }
 echo "c$i [A=$df act $act | $body] $(python3 /tmp/r11u491_drv/pa.py $d/sl.dump) dec=$(grep -B1 -A8 'vpiRhs' $d/sl.dump | awk '/work@top.u/,0' | grep -m1 vpiDecompile | tr -d ' |')"
done

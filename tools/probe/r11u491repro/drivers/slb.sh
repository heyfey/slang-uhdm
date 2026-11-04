#!/bin/bash
# slb.sh <outdir> : reads "ty|default" lines on stdin, runs Surelog, prints B's size/value
SURELOG=/home/heyfey/git-repos/Surelog/build/bin/surelog; UHDM_DUMP=/home/heyfey/git-repos/Surelog/build/third_party/UHDM/bin/uhdm-dump
[ -x "$SURELOG" ] && [ -x "$UHDM_DUMP" ] || exit 1
O=$1; mkdir -p $O; i=0
while IFS='|' read -r ty df act; do i=$((i+1)); d=$O/c$i; mkdir -p $d
 inst="m u(o);"; [ -n "$act" ] && inst="m #(.A($act)) u(o);"
 printf '%s\n' "module m #(parameter $ty A = $df) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule" "module top; logic [7:0] o; $inst endmodule" > $d/dut.sv
 [ -f $d/sl.dump ] || (cd $d && $SURELOG -parse -nobuiltin -nocache -sv dut.sv -mt 0 -mp 0 -o $d/sl >$d/sl.log 2>&1)
 $UHDM_DUMP $d/sl/slpp_all/surelog.uhdm 2>/dev/null > $d/sl.dump
 r=$(grep -n "_parameter: (work@top.u.B)" $d/sl.dump | tail -1 | cut -d: -f1)
 b=$(sed -n "$r,\$p" $d/sl.dump | grep -m2 -E "vpiSize|UINT|INT:" | tr -d ' |\n')
 echo "c$i [$ty = $df${act:+ act $act}] B: $b"
done

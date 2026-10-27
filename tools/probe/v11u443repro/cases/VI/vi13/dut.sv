// § elabIfaceLoopVarReadBinds443

interface ifc;
wire [3:0] a [3]; int s;
initial foreach (a[i]) s = s + i;
endinterface
module top; ifc u(); endmodule

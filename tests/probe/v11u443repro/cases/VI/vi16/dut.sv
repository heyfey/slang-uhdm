// § elabIfaceLoopVarReadBinds443

interface ifc;
wire [3:0] a; int s;
initial foreach (a[i]) s = s + i;
endinterface
module top; ifc u(); endmodule

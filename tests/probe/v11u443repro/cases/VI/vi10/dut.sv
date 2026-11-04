// § elabIfaceLoopVarReadBinds443
interface ifc; logic [3:0][1:0] pv; int s; initial foreach (pv[i, j]) s = s + i + j; endinterface
module top; ifc u(); endmodule

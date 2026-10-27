// § elabIfaceLoopVarReadBinds443
interface ifc; logic [3:0] mem [2]; int s; initial foreach (mem[i, j]) s = s + i + j; endinterface
module top; ifc u(); endmodule

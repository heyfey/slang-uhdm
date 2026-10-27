// § elabIfaceLoopVarReadBinds443
interface ifc #(parameter W = 4); logic [W-1:0] sig; int s; initial foreach (sig[i]) s = s + i; endinterface
module top; ifc #(8) u(); endmodule

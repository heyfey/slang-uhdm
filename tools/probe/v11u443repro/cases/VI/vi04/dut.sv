// § elabIfaceLoopVarReadBinds443
interface ifc; logic [3:0] sig; int s; initial foreach (sig[i]) s = s + i; endinterface
module top; ifc u[2](); endmodule

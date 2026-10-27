// § elabIfaceLoopVarReadBinds443
interface ifc; logic [3:0] sig; int s; final foreach (sig[i]) s = s + i; endinterface
module top; ifc u(); endmodule

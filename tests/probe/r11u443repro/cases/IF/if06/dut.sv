// § elabIfaceLoopVarReadBinds443
interface ifc; logic [3:0] sig; int s; always @(sig) foreach (sig[i]) s = s + i; endinterface
module top; ifc u1(); ifc u2(); endmodule

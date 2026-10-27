// § ifaceLoopVarReadBindsDecl445
interface ifc(input logic [3:0] i);
logic [3:0] sig; int s;
initial foreach (sig[i]) s = s + i;
endinterface
module top; logic [3:0] w; ifc u(w); endmodule

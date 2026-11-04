// § ifaceLoopVarReadBindsDecl445
module top; endmodule
interface ifc;
logic [3:0] sig; int s; int i;
initial foreach (sig[i]) s = s + i;
endinterface

// § ifaceLoopVarReadBindsDecl445
interface ifc;
logic [3:0] sig; int s;
initial foreach (sig[i]) s = s + i;
int i;
endinterface
module top; ifc u(); endmodule

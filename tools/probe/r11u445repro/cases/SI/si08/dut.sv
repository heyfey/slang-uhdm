// § ifaceLoopVarReadBindsDecl445
interface ifc;
logic [3:0] sig;
int s;
logic [7:0] i;
initial foreach (sig[i]) s = s + i;
endinterface
module top; ifc u(); endmodule

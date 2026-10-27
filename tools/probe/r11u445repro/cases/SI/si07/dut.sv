// § ifaceLoopVarReadBindsDecl445
interface ifc;
logic [3:0] sig;
int s;
wire [3:0] i;
initial foreach (sig[i]) s = s + i;
endinterface
module top; ifc u(); endmodule

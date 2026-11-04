// § foreachLoopVarShadowDeclTs445
interface ifc;
logic [3:0] sig;
int s;
initial begin : nb int i; foreach (sig[i]) s = s + i; end
endinterface
module top; ifc u(); endmodule

// § progIfaceParamNoShadow445
interface ifc;
logic [3:0] sig;
int s;
parameter int i = 1;
initial foreach (sig[i]) s = s + i;
endinterface
module top; ifc u(); endmodule

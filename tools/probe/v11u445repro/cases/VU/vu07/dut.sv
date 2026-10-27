// § progIfaceParamNoShadow445
module top; endmodule
interface ifc;
logic [3:0] sig; int s;
parameter int i = 1;
initial foreach (sig[i]) s = s + i;
endinterface

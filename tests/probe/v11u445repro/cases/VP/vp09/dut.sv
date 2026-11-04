// § progIfaceParamNoShadow445
interface ifc;
logic [3:0] sig; int s;
parameter type i = int;
initial foreach (sig[i]) s = s + 1;
endinterface
module top; ifc u(); endmodule

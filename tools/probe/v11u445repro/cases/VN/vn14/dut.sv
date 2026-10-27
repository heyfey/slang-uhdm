// § progIfaceParamNoShadow445
interface ifc;
logic [3:0] sig; int s;
parameter int i = 1;
initial begin int i; foreach (sig[i]) s = s + i; end
endinterface
module top; ifc u(); endmodule

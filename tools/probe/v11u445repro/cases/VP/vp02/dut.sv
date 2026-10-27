// § progIfaceParamNoShadow445
interface ifc #(parameter int i = 1);
logic [3:0] sig; int s;
initial foreach (sig[i]) s = s + i;
endinterface
module top; ifc #(.i(3)) u(); endmodule

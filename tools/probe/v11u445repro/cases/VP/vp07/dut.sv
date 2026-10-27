// § progIfaceParamNoShadow445
interface ifc;
logic [3:0] sig; int s;
parameter int i = 1;
if (1) begin : g initial foreach (sig[i]) s = s + i; end
endinterface
module top; ifc u(); endmodule

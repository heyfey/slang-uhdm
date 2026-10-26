// § connOpUnitParamFold433
localparam S = 2;
interface ifc(input [7:0] a); endinterface
module top; logic [7:0] x; ifc u(.a(x + S)); endmodule

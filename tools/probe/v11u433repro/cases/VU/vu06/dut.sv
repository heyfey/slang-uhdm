// § connOpUnitParamFold433
parameter S = 4'hA;
localparam bit [3:0] T = 4'b0101;
module c(input [7:0] a, input [7:0] b); endmodule
module top; logic [7:0] x; c u(.a(x ^ S), .b(x - T)); endmodule

// § connOpUnitParamFold433
localparam S = 2;
module c(input [7:0] a); endmodule
module top #(parameter S = 5); logic [7:0] x; c u(.a(x + S)); endmodule

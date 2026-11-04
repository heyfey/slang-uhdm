// § connOpUnitParamFold433
localparam S = 2;
module c(input [7:0] a); endmodule
module top; logic [7:0] x; logic [7:0] q; assign q = x + S; c u(.a(x + S)); endmodule

// § unitParamLitForm433v
localparam S = 3'o5;
localparam T = 6'b10_1010;
module c(input [7:0] a, input [7:0] b); endmodule
module top; logic [7:0] x; c u(.a(x + S), .b(x + T)); endmodule

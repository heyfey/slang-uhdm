// § unitParamLitForm433v
localparam S = 2*3+1;
localparam T = 3'o5;
module c(input [63:0] a, input [63:0] b, output [63:0] y); assign y = a ^ b; endmodule
module top(input [63:0] x, output [63:0] y); c u(.a(x + S), .b(x + T), .y(y)); endmodule

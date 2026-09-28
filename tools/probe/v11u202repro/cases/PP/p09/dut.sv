// § portPackedBareImplicitTruncates202v
module sub #(parameter N = 2) (input tri [N-1:0] [3:0] a, input wire signed [N-1:0][3:0] b,
   input unsigned [N-1:0][3:0] c, output [N-1:0][3:0] d);
  assign d = a ^ b ^ c;
endmodule
module p09 (input [2:0][3:0] a, input [2:0][3:0] b, input [2:0][3:0] c, output [2:0][3:0] d);
  sub #(3) u (.a(a), .b(b), .c(c), .d(d));
endmodule

// § portPackedBareImplicitTruncates202v
module sub #(parameter N = 2) (a, b, c, d);
  input wire [N-1:0] [3:0] a;
  input signed [N-1:0] [3:0] b;
  output [N-1:0][3:0] c;
  output unsigned [N-1:0][3:0] d;
  assign c = a;
  assign d = b;
endmodule
module p08 (input [2:0][3:0] a, input signed [2:0][3:0] b, output [2:0][3:0] c, output [2:0][3:0] d);
  sub #(3) u (.a(a), .b(b), .c(c), .d(d));
endmodule

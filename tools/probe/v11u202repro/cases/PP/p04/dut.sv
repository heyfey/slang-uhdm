// § portPackedBareImplicitTruncates202v
module sub #(parameter N = 2) (a, d, e);
  input [N-1:0] [3:0] a;
  output [N-1:0]
     [3:0] d;
  output reg [1:0] [3:0] e;
  assign d = a;
  always @* e = a[1:0];
endmodule
module p04 (input [2:0][3:0] a, output [2:0][3:0] d, output [1:0][3:0] e);
  sub #(3) u (.a(a), .d(d), .e(e));
endmodule

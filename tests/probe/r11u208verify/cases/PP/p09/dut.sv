// § defPortPackedTsKeepsWholeSpan200 § portPackedBareImplicitTruncates202v
module sub #(parameter N = 2) (a, b, y);
  input [N-1:0][3:0] a;
  wire [N-1:0][3:0] a;
  input signed [N-1:0][3:0] b;
  output [N-1:0][3:0] y;
  logic [N-1:0][3:0] y;
  assign y = a ^ b;
endmodule
module p09 (input [2:0][3:0] a, output [2:0][3:0] y);
  sub #(3) u (a, a, y);
endmodule

// § defPortPackedTsKeepsWholeSpan200 § portPackedBareImplicitTruncates202v
module p04 (a, b, y);
  input [1:0][3:0] a;
  wire [1:0][3:0] a;
  input signed [1:0][3:0] b;
  output [1:0][3:0] y;
  logic [1:0][3:0] y;
  assign y = a ^ b;
endmodule

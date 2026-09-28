// § portPackedBareImplicitTruncates202v § defPortPackedTsKeepsWholeSpan200
module sub #(parameter N = 2, parameter W = 4)
  (input [N-1:0][W-1:0][1:0] a, input signed [N-1:0][W-1:0] b, input unsigned [N-1:0][W-1:0] c,
   output [N-1:0][W-1:0] y, output [N-1:0][W-1:0][1:0] z);
  assign y = b ^ c;
  assign z = a;
endmodule
module p07 (input [1:0][3:0][1:0] a, input [1:0][3:0] b, output [1:0][3:0] y, output [1:0][3:0][1:0] z);
  sub u (.a(a), .b(b), .c(b), .y(y), .z(z));
endmodule

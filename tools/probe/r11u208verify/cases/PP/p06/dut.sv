// § defPortPackedTsKeepsWholeSpan200 § portPackedBareImplicitTruncates202v
module sub #(parameter N = 2, parameter W = 4)
  (input wire [N-1:0][W-1:0] a, input tri [N-1:0][W-1:0] b, input var logic [N-1:0][W-1:0] c,
   output reg [N-1:0][W-1:0] d, output wire signed [N-1:0][W-1:0] e);
  always_comb d = a | b | c;
  assign e = a & b;
endmodule
module p06 (input [2:0][4:0] a, output [2:0][4:0] d, output [2:0][4:0] e);
  sub #(.N(3), .W(5)) u (.a(a), .b(a), .c(a), .d(d), .e(e));
endmodule

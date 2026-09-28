// § defPortPackedTsKeepsWholeSpan200 § portPackedBareImplicitTruncates202v
module p01 (input wire [1:0][3:0] a, input tri [1:0][3:0] b, input var logic [1:0][3:0] c,
            output reg [1:0][3:0] d, output wire signed [1:0][3:0] e);
  always_comb d = a | b | c;
  assign e = a & b;
endmodule

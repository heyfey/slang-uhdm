// § portPackedBareImplicitTruncates202v § defPortPackedTsKeepsWholeSpan200
module p02 (input signed [1:0][3:0][2:0] a, input [1:0][1:0][1:0] b, input unsigned [2:0][1:0] c,
            output [1:0][3:0][2:0] y, output [2:0][1:0] z);
  assign y = a ^ {3{b}};
  assign z = c;
endmodule

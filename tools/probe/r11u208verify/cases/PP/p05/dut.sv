// § portPackedBareImplicitTruncates202v § defPortPackedTsKeepsWholeSpan200
module sub (input [3:0] a, input [1:0][3:0] b, output [1:0][3:0] y);
  assign y = b ^ {2{a}};
endmodule
module p05 (input [1:0][3:0] b, input [3:0] a, output [1:0][3:0] y);
  sub u (.*);
endmodule

// § defPortPackedTsKeepsWholeSpan200
module p10 (a, c);
  input [1:0][3:0] a;
  output [1:0][3:0] c;
  wire [1:0][3:0] c;
  assign c = a;
endmodule

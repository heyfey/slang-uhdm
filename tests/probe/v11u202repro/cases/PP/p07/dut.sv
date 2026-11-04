// § defPortPackedTsKeepsWholeSpan200
module p07 (input [1:0][3:0][2:0] a, input tri [1:0][3:0] t, output [1:0][3:0][2:0] o);
  assign o = a;
endmodule

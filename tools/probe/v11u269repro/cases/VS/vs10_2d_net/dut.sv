// § selLhsOpFoldFresh269
module m(output wire [1:0][3:0] w);
  assign w[1][3:0] = {4{1'b1}};
  assign w[0] = 4'h2 * 4'h3;
endmodule
module top(output wire [1:0][3:0] w);
  m u(.w(w));
endmodule

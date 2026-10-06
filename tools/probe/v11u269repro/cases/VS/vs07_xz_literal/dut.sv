// § selLhsOpFoldFresh269
module m(output wire [7:0] w);
  assign w[3:0] = 4'bx1x0 & 4'hF;
  assign w[7:4] = 4'b1z10 | 4'h0;
endmodule
module top(output wire [7:0] w);
  m u(.w(w));
endmodule

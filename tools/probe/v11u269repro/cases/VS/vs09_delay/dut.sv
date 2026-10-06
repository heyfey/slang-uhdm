// § selLhsOpFoldFresh269
module m(output wire [7:0] w);
  assign #1 w[3:0] = 4'h1 + 4'h2;
  assign w[7:4] = 4'h3;
endmodule
module top(output wire [7:0] w);
  m u(.w(w));
endmodule

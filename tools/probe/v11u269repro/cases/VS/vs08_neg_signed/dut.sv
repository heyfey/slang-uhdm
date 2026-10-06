// § selLhsOpFoldFresh269
module m(output wire [7:0] w);
  assign w[3:0] = -4'sd3;
  assign w[7:4] = ~4'h5;
endmodule
module top(output wire [7:0] w);
  m u(.w(w));
endmodule

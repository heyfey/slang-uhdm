// § selLhsOpFoldFresh269
module m #(parameter P = 3) (output wire [3:0] w);
  assign w[0] = P == 3;
  assign w[3:1] = 3'b0;
endmodule
module top(output wire [3:0] a, b);
  m u1(.w(a));
  m #(.P(4)) u2(.w(b));
endmodule

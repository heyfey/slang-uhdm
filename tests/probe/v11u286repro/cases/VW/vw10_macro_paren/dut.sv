// § withCallParenSyntax286
`define S(x) (x.sum() with (item))
module top;
  int q[$] = '{1, 2, 3};
  int r;
  initial r = 1 + `S(q);
endmodule

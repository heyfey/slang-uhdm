// § withCallParenSyntax286
module top;
  int a[4] = '{1, 2, 3, 4};
  int r;
  always_comb r = (a.sum(v) with (v * 2)) + 1;
endmodule

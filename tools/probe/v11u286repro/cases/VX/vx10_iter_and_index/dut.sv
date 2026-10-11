// § withCallParenSyntax286
module top;
  int q[$] = '{1, 2, 3};
  int r;
  initial r = 1 + (q.sum(e) with (e * e.index));
endmodule

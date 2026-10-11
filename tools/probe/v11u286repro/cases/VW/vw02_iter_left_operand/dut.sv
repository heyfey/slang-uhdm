// § withCallParenSyntax286
module top;
  int q[$] = '{1, 2, 3};
  int r;
  initial r = (q.sum(x) with (x + 1)) - 1;
endmodule

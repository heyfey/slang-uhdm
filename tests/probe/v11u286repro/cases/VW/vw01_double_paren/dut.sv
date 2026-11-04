// § withCallParenSyntax286
module top;
  int q[$] = '{1, 2, 3};
  int r;
  initial r = ((q.sum() with (item * 2)));
endmodule

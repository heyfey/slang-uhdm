// § withCallParenSyntax286
module top;
  int q[$] = '{1, 2, 3};
  int r;
  initial for (int i = 0; i < (q.sum() with (item)); i++) r = i;
endmodule

// § withCallParenSyntax286
module top;
  int q[$] = '{1, 2, 3};
  int r;
  initial if ((q.sum() with (int'(item > 2))) > 1) r = 1;
endmodule

// § withCallParenSyntax286
module top;
  int q[$] = '{1, 2, 3};
  int r;
  int a[4];
  initial r = a[(q.sum() with (item)) % 4];
endmodule

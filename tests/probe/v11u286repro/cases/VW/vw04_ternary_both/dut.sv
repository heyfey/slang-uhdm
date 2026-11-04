// § withCallParenSyntax286
module top;
  int q[$] = '{1, 2, 3};
  int r;
  bit c;
  initial r = c ? (q.sum() with (item)) : (q.product() with (item + 1));
endmodule

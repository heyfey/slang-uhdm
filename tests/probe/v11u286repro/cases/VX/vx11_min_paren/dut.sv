// § withCallParenSyntax286
module top;
  int q[$] = '{1, 2, 3};
  int qq[$];
  initial qq = (q.min() with (item));
endmodule

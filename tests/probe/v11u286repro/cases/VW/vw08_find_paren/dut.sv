// § withCallParenSyntax286
module top;
  int q[$] = '{1, 2, 3};
  int qq[$];
  initial qq = (q.find with (item > 1));
endmodule

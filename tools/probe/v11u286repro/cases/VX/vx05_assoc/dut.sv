// § withCallParenSyntax286
module top;
  int aa[string];
  int r;
  initial r = 1 + (aa.sum() with (item));
endmodule

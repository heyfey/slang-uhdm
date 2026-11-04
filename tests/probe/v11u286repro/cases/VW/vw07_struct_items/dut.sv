// § withCallParenSyntax286
module top;
  typedef struct { int a; int b; } s_t;
  s_t qs[$];
  int r;
  initial r = 3 * (qs.sum() with (item.a));
endmodule

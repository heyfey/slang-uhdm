// § enumCastChainKeepsInnerCast493
module top(input int a, output int v);
  typedef struct packed { int f; int g; } s_t;
  s_t s;
  assign s.f = a;
  assign s.g = a;
  assign v = int'(int'(s.f));
endmodule

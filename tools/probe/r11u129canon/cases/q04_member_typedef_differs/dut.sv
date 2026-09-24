package p;
  typedef logic [3:0] ta_t;
  typedef logic [3:0] tb_t;
  typedef struct packed { ta_t m; logic n; } s_t;
endpackage
module top(input p::s_t i, output p::s_t o);
  assign o = i;
endmodule

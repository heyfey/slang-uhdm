package p;
  typedef struct packed { logic [3:0] c; logic d; } s_t;
endpackage
module top(input p::s_t i, output p::s_t o);
  assign o = i;
endmodule

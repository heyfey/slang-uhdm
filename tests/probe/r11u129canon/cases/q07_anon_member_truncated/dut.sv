package p;
  typedef struct packed {
    struct packed { logic a; logic b; } m;
    logic c;
  } t_t;
endpackage
module top(input p::t_t i, output p::t_t o);
  assign o = i;
endmodule

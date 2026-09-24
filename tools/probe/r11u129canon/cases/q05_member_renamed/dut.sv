package p;
  typedef struct packed { logic [3:0] c; logic d; } in_t;
  typedef struct packed { in_t b; logic w; } out_t;
endpackage
module top(input p::out_t i, output p::out_t o);
  assign o = i;
endmodule

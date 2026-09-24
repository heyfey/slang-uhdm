package p;
  typedef struct packed { logic [3:0] c; logic d; } in_t;
  typedef struct packed { logic [1:0] c; logic e; } oth_t;
  typedef struct packed { in_t b; oth_t x; } out_t;
endpackage
module top(input p::out_t i, output p::out_t o);
  assign o = i;
endmodule

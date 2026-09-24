package p;
  typedef struct packed { logic [3:0] c; logic d; } in_t;
  typedef struct packed { in_t b; in_t x; } out_t;
endpackage
module top(input p::out_t i, output logic [4:0] o);
  p::out_t r;
  assign r = i;
  assign o = r.b;
endmodule

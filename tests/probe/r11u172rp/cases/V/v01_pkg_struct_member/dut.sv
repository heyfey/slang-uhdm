package p;
  typedef struct packed { logic [11:00] a; logic [07:05] b; logic [4:0] c; } s_t;
endpackage
module top import p::*; (input s_t i, output logic [11:0] o);
  assign o = i.a;
endmodule

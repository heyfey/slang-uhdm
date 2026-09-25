package p;
  typedef struct { logic [07:00] a [00:01]; } u_t;
endpackage
module top import p::*; (input logic [7:0] i, output logic [7:0] o);
  u_t m;
  assign m.a[0] = i;
  assign o = m.a[0];
endmodule

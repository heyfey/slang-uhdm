// § aliasFoldBoundFile183
package p;
parameter int W = 8;
typedef logic [W-1:0] b_t;
typedef b_t w_t;
typedef struct packed { w_t v; logic x; } s_t;
endpackage
module top import p::*; (input s_t a, output logic [7:0] o);
  assign o = a.v;
endmodule

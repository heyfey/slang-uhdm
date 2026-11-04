// § aliasFoldBoundFile183
package p;
typedef logic [15-1:0] i_t;
typedef i_t l_t;
endpackage
module top(input logic [14:0] a, output logic [14:0] o);
  import p::*;
  l_t r;
  assign r = a;
  assign o = r;
endmodule

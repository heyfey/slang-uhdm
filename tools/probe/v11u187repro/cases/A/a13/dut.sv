// § aliasFoldBoundFile183 (an alias of an alias)
package p;
typedef logic [5:0] a_t;
typedef a_t b_t;
typedef b_t c_t;
endpackage
module top import p::*; (input c_t a, output b_t o);
  assign o = a;
endmodule

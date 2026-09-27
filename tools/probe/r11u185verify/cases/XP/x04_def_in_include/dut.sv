// § externProtoFormalsFromPrototype175
package p;
  typedef logic [7:0] byte_t;
  class c;
    extern function byte_t f(byte_t a,
                             int unsigned n = 2);
    extern task t(input byte_t a, output byte_t b);
  endclass
`include "c_impl.svh"
endpackage
module top;
  import p::*;
  c o; byte_t r;
  initial begin o = new; r = o.f(8'h3); o.t(r, r); end
endmodule

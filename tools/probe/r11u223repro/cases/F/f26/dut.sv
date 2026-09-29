// § tfArgScalarTdWriter223 — a header holding a function with typedef formals, included in two modules
package p;
  typedef int UVM_FILE;
  typedef bit my_bit_t;
endpackage
module m1(output int o);
  import p::*;
  `include "hdr.svh"
  assign o = hset(1, 1'b0);
endmodule
module top(output int o);
  import p::*;
  `include "hdr.svh"
  m1 u(.o(o));
endmodule

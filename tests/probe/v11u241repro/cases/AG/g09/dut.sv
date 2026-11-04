// § cloneAggTsAtHomeListing241
`define FML(T) T
package p;
`include "types.svh"
  function automatic int f(`FML(s_t) x);
    return x.a;
  endfunction
  function automatic int g(s_t
                           y);
    s_t z;
    z = y;
    return z.b;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import p::*;
  int v;
endmodule

// § cloneOwnAggMemberChainName285
// a struct typedef local to the method
package a; typedef bit [7:0] w_t;
  class C; extern function int m(); endclass
  function int C::m(); typedef struct { w_t lo; int n; } l_t; l_t r; return r.n; endfunction endpackage
package b; import a::*; function automatic int g(); C c; c = new(); return c.m(); endfunction endpackage
module top(output int o); import b::*; int r; initial r = g(); assign o = r; endmodule

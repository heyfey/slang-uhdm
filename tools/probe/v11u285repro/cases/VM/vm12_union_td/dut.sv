// § cloneOwnAggMemberChainName285
// a union local with typedef members
package a; typedef bit [7:0] w_t; typedef union { w_t lo; int n; } u_t;
  class C; extern function int m(); endclass
  function int C::m(); u_t r; return r.n; endfunction endpackage
package b; import a::*; function automatic int g(); C c; c = new(); return c.m(); endfunction endpackage
module top(output int o); import b::*; int r; initial r = g(); assign o = r; endmodule

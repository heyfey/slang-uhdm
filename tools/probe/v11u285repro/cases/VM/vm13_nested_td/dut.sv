// § cloneOwnAggMemberChainName285
// a nested struct member whose own member is a typedef
package a; typedef bit [7:0] w_t; typedef struct { w_t x; } i_t; typedef struct { i_t in; int n; } s_t;
  class C; extern function int m(); endclass
  function int C::m(); s_t r; return int'(r.in.x); endfunction endpackage
package b; import a::*; function automatic int g(); C c; c = new(); return c.m(); endfunction endpackage
module top(output int o); import b::*; int r; initial r = g(); assign o = r; endmodule

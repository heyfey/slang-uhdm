// § cloneMembTdOwnCopy285
// a member typed by a parameter-sized typedef
package a; parameter int W = 12; typedef logic [W-1:0] w_t; typedef struct { w_t lo; int n; } s_t;
  class C; extern function int m(); endclass
  function int C::m(); s_t r; return int'(r.lo); endfunction endpackage
package b; import a::*; function automatic int g(); C c; c = new(); return c.m(); endfunction endpackage
module top(output int o); import b::*; int r; initial r = g(); assign o = r; endmodule

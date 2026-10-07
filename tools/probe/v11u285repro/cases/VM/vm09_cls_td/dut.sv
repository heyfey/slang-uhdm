// § cloneMembTdOwnCopy285
// a class-scoped vector typedef as the member type
package a;
  class C; typedef bit [5:0] cw_t; typedef struct { cw_t lo; int n; } s_t; extern function int m(); endclass
  function int C::m(); s_t r; return int'(r.lo); endfunction endpackage
package b; import a::*; function automatic int g(); C c; c = new(); return c.m(); endfunction endpackage
module top(output int o); import b::*; int r; initial r = g(); assign o = r; endmodule

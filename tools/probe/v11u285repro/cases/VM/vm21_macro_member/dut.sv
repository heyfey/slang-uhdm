// § cloneMembTdOwnCopy285
// a member typed by a typedef from a macro argument list
`define DECL(t, n) t n;
package a; typedef bit [7:0] w_t; typedef struct { `DECL(w_t, lo) int n; } s_t;
  class C; extern function int m(); endclass
  function int C::m(); s_t r; return int'(r.lo); endfunction endpackage
package b; import a::*; function automatic int g(); C c; c = new(); return c.m(); endfunction endpackage
module top(output int o); import b::*; int r; initial r = g(); assign o = r; endmodule

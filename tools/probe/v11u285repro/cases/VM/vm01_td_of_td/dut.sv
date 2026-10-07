// § cloneMembTdOwnCopy285
// a member typed by a typedef of a typedef
package a; typedef bit [7:0] w_t; typedef w_t w2_t; typedef struct { w2_t lo; int n; } s_t;
  class C; extern function int m(); endclass
  function int C::m(); s_t r; return int'(r.lo); endfunction endpackage
package b; import a::*; function automatic int g(); C c; c = new(); return c.m(); endfunction endpackage
module top(output int o); import b::*; int r; initial r = g(); assign o = r; endmodule

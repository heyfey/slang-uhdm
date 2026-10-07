// § cloneMembTdOwnCopy285
// two importing packages calling the method
package a; typedef bit [7:0] w_t; typedef struct { w_t lo; int n; } s_t;
  class C; extern function int m(); endclass
  function int C::m(); s_t r; return int'(r.lo); endfunction endpackage
package b; import a::*; function automatic int g(); C c; c = new(); return c.m(); endfunction endpackage
package b2; import a::*; function automatic int g2(); C c; c = new(); return c.m(); endfunction endpackage
module top(output int o); import b::*; import b2::*; int r; initial r = g() + g2(); assign o = r; endmodule

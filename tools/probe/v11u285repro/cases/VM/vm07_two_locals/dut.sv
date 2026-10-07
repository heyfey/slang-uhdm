// § cloneMembTdOwnCopy285
// two locals of one struct type
package a; typedef bit [7:0] w_t; typedef struct { w_t lo; } s_t;
  class C; extern function int m(); endclass
  function int C::m(); s_t r; s_t q; q = r; return int'(q.lo); endfunction endpackage
package b; import a::*; function automatic int g(); C c; c = new(); return c.m(); endfunction endpackage
module top(output int o); import b::*; int r; initial r = g(); assign o = r; endmodule

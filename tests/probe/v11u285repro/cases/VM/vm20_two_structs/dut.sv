// § cloneMembTdOwnCopy285
// two struct types sharing one member typedef
package a; typedef bit [7:0] w_t; typedef struct { w_t lo; } s_t; typedef struct { w_t x; w_t y; } s2_t;
  class C; extern function int m(); endclass
  function int C::m(); s_t r; s2_t z; return int'(r.lo) + int'(z.x); endfunction endpackage
package b; import a::*; function automatic int g(); C c; c = new(); return c.m(); endfunction endpackage
module top(output int o); import b::*; int r; initial r = g(); assign o = r; endmodule

// § cloneMembTdOwnCopy285
// a member typed by a packed struct typedef and a vector typedef
package a; typedef bit [7:0] w_t; typedef struct packed { w_t p; } ps_t; typedef struct { ps_t ps; w_t lo; } s_t;
  class C; extern function int m(); endclass
  function int C::m(); s_t r; return int'(r.lo); endfunction endpackage
package b; import a::*; function automatic int g(); C c; c = new(); return c.m(); endfunction endpackage
module top(output int o); import b::*; int r; initial r = g(); assign o = r; endmodule

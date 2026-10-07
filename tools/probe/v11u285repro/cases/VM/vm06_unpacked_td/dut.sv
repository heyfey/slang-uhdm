// § cloneMembTdOwnCopy285
// a member typed by an unpacked array typedef
package a; typedef int ua_t [2]; typedef bit [3:0] w_t; typedef struct { ua_t u; w_t lo; } s_t;
  class C; extern function int m(); endclass
  function int C::m(); s_t r; return r.u[0]; endfunction endpackage
package b; import a::*; function automatic int g(); C c; c = new(); return c.m(); endfunction endpackage
module top(output int o); import b::*; int r; initial r = g(); assign o = r; endmodule

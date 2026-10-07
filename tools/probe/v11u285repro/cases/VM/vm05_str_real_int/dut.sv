// § cloneMembTdOwnCopy285
// members typed by string, real and integer typedefs
package a; typedef string st_t; typedef real r_t; typedef integer i_t; typedef struct { st_t s; r_t x; i_t k; } s_t;
  class C; extern function int m(); endclass
  function int C::m(); s_t r; return r.k; endfunction endpackage
package b; import a::*; function automatic int g(); C c; c = new(); return c.m(); endfunction endpackage
module top(output int o); import b::*; int r; initial r = g(); assign o = r; endmodule

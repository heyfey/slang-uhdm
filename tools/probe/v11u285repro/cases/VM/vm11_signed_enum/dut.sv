// § cloneMembTdOwnCopy285
// a member typed by a signed logic typedef and an enum member side by side
package a; typedef logic signed [7:0] w_t; typedef enum bit [1:0] {E0, E1} e_t; typedef struct { w_t lo; e_t e; } s_t;
  class C; extern function int m(); endclass
  function int C::m(); s_t r; return int'(r.lo) + int'(r.e); endfunction endpackage
package b; import a::*; function automatic int g(); C c; c = new(); return c.m(); endfunction endpackage
module top(output int o); import b::*; int r; initial r = g(); assign o = r; endmodule

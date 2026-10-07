// § cloneMembTdOwnCopy285
// the struct local declared in a for loop block
package a; typedef bit [7:0] w_t; typedef struct { w_t lo; } s_t;
  class C; extern function int m(); endclass
  function int C::m(); int k = 0; for (int i = 0; i < 2; i++) begin s_t r; r.lo = 8'(i); k += int'(r.lo); end return k; endfunction endpackage
package b; import a::*; function automatic int g(); C c; c = new(); return c.m(); endfunction endpackage
module top(output int o); import b::*; int r; initial r = g(); assign o = r; endmodule

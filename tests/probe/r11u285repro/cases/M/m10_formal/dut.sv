// § cloneMembTdOwnCopy285
// a struct formal and a struct return
package a; typedef bit [7:0] w_t; typedef struct { w_t lo; } s_t;
  function automatic s_t f(s_t i); s_t o; o = i; return o; endfunction endpackage
package b; import a::*; function automatic int g(); s_t z; z = f(z); return int'(z.lo); endfunction endpackage
module top; import b::*; int r; initial r = g(); endmodule

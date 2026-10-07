// § cloneMembTdOwnCopy285
// CRLF line ends, a bit vector typedef member
package a; typedef bit [15:0] w_t; typedef struct { w_t lo; w_t hi; } s_t;
  class C; extern function int m(); endclass
  function int C::m(); s_t r; return int'(r.lo); endfunction endpackage
package b; import a::*; function automatic int g(); C c; c = new(); return c.m(); endfunction endpackage
module top(output int o); import b::*; int r; initial r = g(); assign o = r; endmodule

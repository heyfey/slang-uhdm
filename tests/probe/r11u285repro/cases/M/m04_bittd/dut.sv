// § cloneMembTdOwnCopy285
// a struct member typed by a bit vector typedef
package a; typedef bit [15:0] w_t; typedef struct { w_t lo; w_t hi; int n; } s_t;
  class C; extern function int m(); endclass
  function int C::m(); s_t r; return int'(r.lo) + int'(r.hi); endfunction endpackage
package b; import a::*; function automatic int g(); C c; c = new(); return c.m(); endfunction endpackage
module top; import b::*; int r; initial r = g(); endmodule

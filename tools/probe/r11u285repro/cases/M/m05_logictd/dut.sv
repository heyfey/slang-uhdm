// § cloneMembTdOwnCopy285
// a struct member typed by a logic vector typedef, in a package function
package a; typedef logic [7:0] w_t; typedef struct { w_t lo; int n; } s_t;
  function automatic int f(); s_t r; r.lo = 8'h1; return int'(r.lo); endfunction endpackage
package b; import a::*; function automatic int g(); return f(); endfunction endpackage
module top; import b::*; int r; initial r = g(); endmodule

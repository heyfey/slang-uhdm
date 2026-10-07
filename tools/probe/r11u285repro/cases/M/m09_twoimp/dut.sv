// § cloneMembTdOwnCopy285
// two importers of the same home function
package a; typedef bit [7:0] w_t; typedef struct { w_t lo; } s_t;
  function automatic int f(); s_t r; r.lo = 1; return int'(r.lo); endfunction endpackage
package b; import a::*; function automatic int g(); return f(); endfunction endpackage
package c; import a::*; function automatic int h(); return f(); endfunction endpackage
module top; import b::*; import c::*; int r; initial r = g() + h(); endmodule

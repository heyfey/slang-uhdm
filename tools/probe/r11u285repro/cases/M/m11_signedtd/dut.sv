// § cloneMembTdOwnCopy285
// a signed logic typedef member and an unpacked member dimension
package a; typedef logic signed [7:0] w_t; typedef struct { w_t lo [2]; w_t hi; } s_t;
  function automatic int f(); s_t r; r.hi = 1; return int'(r.hi); endfunction endpackage
package b; import a::*; function automatic int g(); return f(); endfunction endpackage
module top; import b::*; int r; initial r = g(); endmodule

// § cloneMembTdOwnCopy285
// a member typed by a nested struct typedef and a bit typedef
package a; typedef bit [3:0] w_t; typedef struct { w_t z; } i_t; typedef struct { i_t in; w_t w; } s_t;
  function automatic int f(); s_t r; r.w = 1; return int'(r.w); endfunction endpackage
package b; import a::*; function automatic int g(); return f(); endfunction endpackage
module top; import b::*; int r; initial r = g(); endmodule

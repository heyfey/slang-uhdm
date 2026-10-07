// § cloneMembTdOwnCopy285
// a member typed by an int typedef and a typedef of a typedef
package a; typedef int i_t; typedef i_t j_t; typedef struct { i_t p; j_t q; } s_t;
  function automatic int f(); s_t r; r.p = 1; return r.p + r.q; endfunction endpackage
package b; import a::*; function automatic int g(); return f(); endfunction endpackage
module top; import b::*; int r; initial r = g(); endmodule

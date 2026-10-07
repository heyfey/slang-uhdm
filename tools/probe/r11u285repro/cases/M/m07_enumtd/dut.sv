// § cloneMembTdOwnCopy285
// control: a member typed by an enum typedef (pass 265's law)
package a; typedef enum { E0, E1 } e_t; typedef struct { e_t k; int n; } s_t;
  function automatic int f(); s_t r; r.n = 1; return r.n; endfunction endpackage
package b; import a::*; function automatic int g(); return f(); endfunction endpackage
module top; import b::*; int r; initial r = g(); endmodule

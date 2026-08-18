// r10earl60 arm A — the ELAB param_assign Rhs TYPESPEC grid.
//
// One row per (declared type of the module localparam) x (kind of the package
// member it references) x (parenthesised / bare / operation) x (package
// wildcard-IMPORTED or referenced by explicit scope only).  The module under
// test is WRAPPED (`a1 -> u_sub`), because a module that is the TOP gives
// design::Compare nothing to disagree about first (r10earl59's a1 lesson) and
// because the corpus shape -- tlul_socket_m1, dm_mem -- is never a top.
package p_noimp;
  localparam int          A8  = 8;          // package LOCALPARAM, int
  localparam logic [11:0] B12 = 12'h380;    // package LOCALPARAM, ranged logic
  parameter  int          C9  = 9;          // package PARAMETER, int
endpackage

package p_imp;
  parameter int N = 12;                     // package PARAMETER
  localparam int L = 5;                     // package LOCALPARAM
endpackage

module sub ();
  localparam int DbgBits = 12;
  // p_noimp is NOT imported anywhere: explicit scope only (dm_mem / tlul_socket_m1)
  localparam int unsigned        g1_intU      = p_noimp::A8;
  localparam int                 g2_int       = p_noimp::A8;
  localparam logic [DbgBits-1:0] g3_paren     = (p_noimp::B12);
  localparam logic [11:0]        g4_nopar     = p_noimp::B12;
  localparam int                 g5_fromParam = p_noimp::C9;
  localparam int                 g6_op        = p_noimp::A8 + 1;
  localparam                     g7_untyped   = p_noimp::A8;
endmodule

module subi ();
  import p_imp::*;
  localparam int i1_shadow = p_imp::N;      // local name SHADOWS the imported one
  localparam int i2_other  = p_imp::L;      // different name
  localparam int i3_bare   = N;             // bare reference to the imported name
endmodule

module subp #(parameter int PP = 3) ();
  localparam int p1 = PP;
endmodule

module a1 ();
  sub  u_sub  ();
  subi u_subi ();
  subp #(.PP(p_noimp::A8)) u_subp ();       // instantiation-site OVERRIDE from a pkg
endmodule

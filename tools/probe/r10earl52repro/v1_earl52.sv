// r10earl52 verifier v1 — THE CROSS-PACKAGE HOP, the one cell a3 showed the
// law moving WRONG->WRONG (U_pkg).  Varies the PACKAGE source's own Rhs shape
// (literal / ternary / operation / hop) against `int` and vector targets, so
// the fence can be stated from measurement instead of guessed.
package v1p_earl52;
  localparam bit        PC     = 1'b0;
  localparam bit        S_lit1 = 1'b1;          // pkg Rhs IS a constant
  localparam bit [7:0]  S_lit8 = 8'hab;         // pkg Rhs IS a constant
  localparam int        S_tern = PC ? 1'b0 : 1'b1;   // pkg Rhs is an OPERATION
  localparam bit        S_tb   = PC ? 1'b0 : 1'b1;   // pkg Rhs is an OPERATION
  localparam int        S_op   = 1'b1 | 1'b0;        // pkg Rhs is an OPERATION
  localparam int        S_hop  = S_lit1;             // pkg Rhs is a REF
endpackage

module v1_earl52 ();
  // --- package source read into `int`
  localparam int       R_lit1 = v1p_earl52::S_lit1;
  localparam int       R_lit8 = v1p_earl52::S_lit8;
  localparam int       R_tern = v1p_earl52::S_tern;
  localparam int       R_tb   = v1p_earl52::S_tb;
  localparam int       R_op   = v1p_earl52::S_op;
  localparam int       R_hop  = v1p_earl52::S_hop;
  // --- the same sources into a vector target
  localparam logic [7:0] L_lit1 = v1p_earl52::S_lit1;
  localparam logic [7:0] L_lit8 = v1p_earl52::S_lit8;
  localparam logic [7:0] L_tern = v1p_earl52::S_tern;
  // --- the SAME-SCOPE twins (a3 already showed these read INT:-1)
  localparam bit       M_lit1 = 1'b1;
  localparam int       M_rlit = M_lit1;
  localparam int       M_tern = 1'b0 ? 1'b0 : 1'b1;
  localparam int       M_rter = M_tern;
  // --- a WILDCARD-imported package source (no ::)
  import v1p_earl52::*;
  localparam int       I_lit1 = S_lit1;
  localparam int       I_tern = S_tern;
endmodule

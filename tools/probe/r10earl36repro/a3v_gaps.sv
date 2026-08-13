// r10earl36 VERIFIER arm a3 — THE EMPTY PRODUCT CELLS of the implementer's grid.
//
// a1/a2 cross carrier x bound-symbol-kind x shadow x bound-form x depth x
// position x import-site.  Six product cells are NOT in either file; each is
// reachable by the new arm's gate (or is decided by an abstain it never
// measured).  Every value is chosen so the PACKAGE and the MODULE disagree,
// so each printed constant names which symbol was resolved.
//
//   g1  RIGHT-bound position     [0:SH_P-1]  (a1 only ever puts the name LEFT)
//   g2  DELETED — VACUOUS, not merely uncovered.  An EXPLICIT (non-wildcard)
//       `import q3c::EX_P;` CANNOT be shadowed by a module-local `EX_P`: slang
//       rejects it as `error: redefinition of 'EX_P' [-Wredefinition]`.  So
//       restricting wildcardPkgParamNamed9's walk to WILDCARD imports loses
//       nothing and "import kind" is not an axis at all.  (Verifier V6.)
//   g3  package declares the name as a NON-parameter (typedef)
//   g4  TWO wildcard imports BOTH declaring the name (first-found-wins)
//   g5  GENERATE-block-scoped net with a shadowed bound (the walk's
//       InstanceBody stop condition)
//   g6  UNPACKED dim  q::f_t u [SH_P-1:0]  (array_typespec, not packed)
//
// MEASURED, golden / pristine / patched (bndcen.py three-way):
//   g1  golden FOLDS the right bound to the PACKAGE value (UINT:5 ->its@38:14);
//       pristine ref_obj(SH_P); PATCHED == GOLDEN.  Gap closed, arm correct.
//   g3  golden KEEPS ref_obj(NPNAME); we abstain.  The `kind == Parameter`
//       filter is golden-faithful.
//   g4  golden folds to 7 = q3::AMB, the FIRST-imported package; PATCHED
//       matches.  First-found-wins agrees with golden ON THIS ORDERING SAMPLE;
//       the ordering is INHERITED from § shadowedImportBoundFold, not
//       established here.
//   g5  *** GOLDEN DOES NOT SUBSTITUTE ***  golden keeps the def-view op11 +
//       ref_obj(GB_P); we fold the whole bound to INT:8 sz64 in BOTH views and
//       never emit the op form.  PRE-EXISTING (patched == pristine) and a
//       COUNTEREXAMPLE to the law's stated "port or body net all fold the
//       same": the CONTAINER is a discriminator golden uses.  Widening this
//       arm to generate scopes would OVER-FIRE.  Verifier residue R6.
//   g6  golden == pristine == patched.  No divergence.
package q3;
  localparam int SH_P   = 5;   // module twin = 9
  localparam int GB_P   = 6;   // module twin = 9   (generate-block cell)
  localparam int AMB    = 7;   // ALSO declared by q3b (value 8)
  typedef struct packed { logic q; } f_t;
  typedef logic NPNAME;        // the NAME the module declares as a parameter
endpackage

package q3b;
  localparam int AMB = 8;      // the SECOND wildcard-imported declaration
endpackage

package q3c;
  localparam int EX_P = 4;     // reached only by an EXPLICIT import
  typedef struct packed { logic q; } g_t;
endpackage

// ---- g1 / g3 / g4 / g5 / g6 : wildcard imports in the BODY (flash_mp shape)
module m3a #(
  parameter  int SH_P   = 9,
  parameter  int GB_P   = 9,
  parameter  int AMB    = 9,
  parameter  int NPNAME = 9
) (
  input logic clk_i,
  input  q3::f_t [0:SH_P-1]   g1_right,   // g1 RIGHT bound carries the name
  input  q3::f_t [NPNAME-1:0] g3_nonparam,// g3 pkg name is a TYPEDEF
  input  q3::f_t [AMB-1:0]    g4_ambig,   // g4 two wildcard imports declare AMB
  output logic                o_o
);
  import q3::*;
  import q3b::*;

  q3::f_t u6_unpacked [SH_P-1:0];         // g6 UNPACKED dim

  if (1) begin : gb
    q3::f_t [GB_P-1:0] g5_genblk;         // g5 generate-block-scoped net
    assign g5_genblk = '0;
  end

  assign o_o = clk_i;
  assign u6_unpacked[0] = '0;
endmodule

module top3;
  logic clk;
  logic o1;
  m3a u1 (.clk_i(clk), .o_o(o1), .g1_right(), .g3_nonparam(), .g4_ambig());
endmodule

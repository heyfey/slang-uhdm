// r10earl34 VERIFIER ARM V1 — THE VIEW SPLIT, the brief-mandated cell (f)
// that a1/a2/a3 do not contain.
//
// The brief said: "(f) def view vs elab view of the same name (the 36-vs-48
// asymmetry suggests a view split)".  Every implementer arm is a SINGLE
// module with no instantiation, so Surelog emits ONE view of every name and
// the arms cannot see a view split at all.  This arm instantiates a
// submodule, so the golden database carries the SAME hier_path name in both
// `allModules` (module-compile / def) and `topModules` (elaborated) views.
//
// If golden reduced only in the elab view we would now be WRONG in the def
// view design-wide, and no implementer cell could have shown it.
//
// Also here: multi-dim base select with two package indexes, and an RVALUE
// (not LHS) package-indexed path.

package v1_pkg;
  localparam int PkgLp  = 8;
  localparam int PkgTwo = 2;
endpackage

typedef struct packed {
  logic [3:0] q;
} v1_inner_t;

typedef struct packed {
  v1_inner_t base;
  logic [15:0] a_source;
} v1_cfg_t;

module v1_sub import v1_pkg::*; (
  input  logic       clk,
  output logic [3:0] o_lhs,
  output logic [3:0] o_rhs
);
  // cell v1_lhs : cont-assign LVALUE, package localparam index (the target)
  v1_cfg_t [PkgLp:0] arr;
  assign arr[PkgLp].base.q = 4'h0;
  assign o_lhs = arr[0].base.q;

  // cell v1_rhs : the SAME shape read as an RVALUE
  v1_cfg_t [PkgLp:0] arr_r;
  assign o_rhs = arr_r[PkgLp].base.q;

  // cell v1_2d : MULTI-DIM base select, BOTH dims package localparams
  v1_cfg_t [PkgLp:0][PkgLp:0] arr2d;
  assign arr2d[PkgLp][PkgTwo].base.q = 4'h1;
endmodule

module v1_view (
  input  logic       clk,
  output logic [3:0] a,
  output logic [3:0] b
);
  v1_sub u_sub (.clk(clk), .o_lhs(a), .o_rhs(b));
endmodule

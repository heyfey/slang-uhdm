// r10earl34 VERIFIER ARM V5 — SHARPENING THE CONCAT REFUTATION.
//
// v2_kinds proved golden does NOT substitute a package localparam whose
// initializer is a CONCATENATION (golden keeps `arr2[PkgCat]` and keeps a
// `ref_obj` as the index), while the patched build prints `arr2[9]`.
// This arm asks WHICH initializer kinds share that behaviour, so the guard
// that fixes it can be written to a measured grid instead of to one cell.
//
//   InLit  : sized literal          (already known to fold, as its spelling)
//   InArith: arithmetic over params (already known to fold, as a decimal)
//   InCat  : concatenation          (measured: does NOT fold)
//   InRep  : replication            ?
//   InFunc : $clog2(...)            ?
//   InCond : ternary                ?
//   InCast : sized cast             ?

package v5_pkg;
  localparam int InLit   = 4;
  localparam int InArith = InLit + 2;          // 6
  localparam int InCat   = {2'b10, 2'b01};     // 9
  localparam int InRep   = {2{2'b01}};         // 5
  localparam int InFunc  = $clog2(128);        // 7
  localparam int InCond  = (InLit > 2) ? 3 : 8;
  localparam int InCast  = int'(2);
endpackage

typedef struct packed {
  logic [3:0] q;
} v5_inner_t;

typedef struct packed {
  v5_inner_t base;
} v5_cfg_t;

module v5_init import v5_pkg::*; (
  output logic [3:0] o
);
  v5_cfg_t [15:0] a1, a2, a3, a4, a5, a6, a7;

  assign a1[InLit].base.q   = 4'h0;
  assign a2[InArith].base.q = 4'h1;
  assign a3[InCat].base.q   = 4'h2;
  assign a4[InRep].base.q   = 4'h3;
  assign a5[InFunc].base.q  = 4'h4;
  assign a6[InCond].base.q  = 4'h5;
  assign a7[InCast].base.q  = 4'h6;

  assign o = a1[0].base.q;
endmodule

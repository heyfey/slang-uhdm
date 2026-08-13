// r10earl34 VERIFIER ARM V4 — the cells where § hpMixedIdxPkgFold34 MEETS the
// two standing laws my brief names: § hpSelParenStrip (parenthesis removal in
// a hier_path display name, TypeEmit.cpp:12287) and the macro guard inside
// `rawTextPkgFold`.
//
//   v4_paren  : `arr[(PkgLp-1)]` — golden's re-lex DROPS the parentheses.
//               `idxText34` calls `spaceIdxOps`, NOT the paren-stripping
//               renderer, so the fold and the strip live in different
//               builders.  Does the element-select name keep them?
//   v4_macro  : the index is spelled by a MACRO.  `rawTextPkgFold` refuses to
//               splice when `sm->isMacroLoc(range.start())`, so the fold must
//               ABSTAIN and the name must read exactly as pristine did.
//   v4_nested : the package parameter is read from a package that imports it
//               from ANOTHER package — the declaring scope is still a package,
//               so the gate fires; the question is WHICH text is spliced.
//   v4_signed : a NEGATIVE package localparam, whose decimal rendering carries
//               a sign character into a name.

`define V4IDX PkgLp

package v4_base_pkg;
  localparam int Far = 6;
endpackage

package v4_pkg;
  import v4_base_pkg::*;
  localparam int PkgLp  = 8;
  localparam int Near   = Far;      // = 6, initialised from another package
  localparam int PkgNeg = -3;
endpackage

typedef struct packed {
  logic [3:0] q;
} v4_inner_t;

typedef struct packed {
  v4_inner_t base;
} v4_cfg_t;

module v4_paren import v4_pkg::*; (
  output logic [3:0] o
);
  v4_cfg_t [15:0] arr;
  v4_cfg_t [15:0] arr2;
  v4_cfg_t [15:0] arr3;
  v4_cfg_t [15:0] arr4;

  assign arr[(PkgLp-1)].base.q = 4'h0;   // v4_paren
  assign arr2[`V4IDX].base.q   = 4'h1;   // v4_macro
  assign arr3[Near].base.q     = 4'h2;   // v4_nested
  assign arr4[PkgNeg+5].base.q = 4'h3;   // v4_signed

  assign o = arr[0].base.q;
endmodule

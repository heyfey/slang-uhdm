// r10earl34 ARM A2 — THE SEPARATING GRID.
//
// A1 said "package-declared reduces, module-declared does not".  The corpus
// REFUTED that immediately: tlul_socket_m1's IDW/STIDW are MODULE-LOCAL
// localparams (tlul_socket_m1.sv:72-73) and golden reduces them —
//     tl_h_i[i].a_source[0+:(IDW-STIDW)]  ->  tl_h_i[i].a_source[0+:8 - 1]
//     tl_h_i[i].a_source[IDW-1 -: STIDW]  ->  tl_h_i[i].a_source[8 - 1-:1]
// ...while the GENVAR `[i]` in the SAME name does not.
//
// The one thing every corpus reducer has in common that A1's non-reducers do
// not is that it sits inside a COMPOUND index expression.  This arm separates
// the four candidate discriminators that A1 confounded:
//
//   (1) COMPOUND vs BARE index expression
//   (2) BASE-position select vs TRAILING (post-member-access) select
//   (3) BIT-select vs PART-select (`:` / `+:` / `-:`)
//   (4) where the symbol is declared (package / module / genvar)
//
// Every parameter has a DISTINCT value so no two cells collide on one array
// element (a duplicate cont-assign is an elaboration error, not a datapoint).

package e34b_pkg;
  localparam int PkgLp  = 8;
  localparam int TL_AIW = 9;
endpackage

typedef struct packed {
  logic [3:0] q;
} e34b_inner_t;

typedef struct packed {
  e34b_inner_t base;
  logic [15:0] a_source;
} e34b_cfg_t;

module a2_shape import e34b_pkg::*; (
  input  e34b_cfg_t [7:0] tl_h_i,
  output logic [63:0] o
);

  localparam int LocLp    = 6;                // plain module localparam
  localparam int FromPkg  = e34b_pkg::TL_AIW; // the IDW shape: init FROM a package
  localparam int FromClog = $clog2(32);       // the STIDW shape: init from $clog2
  parameter  int ModP     = 4;

  e34b_cfg_t [15:0] arr;   // BARE-index cells
  e34b_cfg_t [15:0] arr2;  // COMPOUND-index cells

  // ===== (1) BASE position, BARE index — A1's cells, restated =============
  assign arr[PkgLp].base.q    = 4'h0;  // bb_pkg     : package  , bare , base
  assign arr[LocLp].base.q    = 4'h1;  // bb_loc     : module lp, bare , base
  assign arr[FromPkg].base.q  = 4'h2;  // bb_frompkg : module lp initialised from pkg
  assign arr[FromClog].base.q = 4'h3;  // bb_fromclog: module lp initialised from $clog2
  assign arr[ModP].base.q     = 4'h4;  // bb_modp    : module parameter

  // ===== (2) BASE position, COMPOUND index ================================
  assign arr2[PkgLp-1].base.q    = 4'h0; // bc_pkg
  assign arr2[LocLp-1].base.q    = 4'h1; // bc_loc      <-- THE DECIDER
  assign arr2[FromPkg-1].base.q  = 4'h2; // bc_frompkg
  assign arr2[FromClog+1].base.q = 4'h3; // bc_fromclog
  assign arr2[ModP-1].base.q     = 4'h4; // bc_modp     <-- THE DECIDER

  // ===== (3) TRAILING position, BARE bit-select ===========================
  assign o[0] = tl_h_i[0].a_source[PkgLp];   // tb_pkg
  assign o[1] = tl_h_i[0].a_source[LocLp];   // tb_loc   <-- THE DECIDER
  assign o[2] = tl_h_i[0].a_source[ModP];    // tb_modp

  // ===== (4) TRAILING position, COMPOUND bit-select =======================
  assign o[3] = tl_h_i[0].a_source[PkgLp-1]; // tc_pkg
  assign o[4] = tl_h_i[0].a_source[LocLp-1]; // tc_loc
  assign o[5] = tl_h_i[0].a_source[ModP-1];  // tc_modp

  // ===== (5) TRAILING PART-selects — the exact tlul_socket_m1 shapes ======
  assign o[13:8]  = tl_h_i[0].a_source[0+:(FromPkg-FromClog)]; // tp_compound (9-5=4).. width 4
  assign o[17:16] = tl_h_i[0].a_source[FromPkg-1 -: 2];        // tp_minus
  assign o[23:18] = tl_h_i[0].a_source[0+:LocLp];              // tp_bare_loc  (6)
  assign o[33:26] = tl_h_i[0].a_source[0+:PkgLp];              // tp_bare_pkg  (8)
  assign o[39:34] = tl_h_i[0].a_source[LocLp-1:0];             // tr_compound_loc (6)
  assign o[49:42] = tl_h_i[0].a_source[PkgLp-1:0];             // tr_compound_pkg (8)

  // (6) BASE range-selects are not legal ahead of a member access
  //     (`arr[a:b][0].base.q` — SNT:PA0207), so that row of the grid has no
  //     cell to measure and is recorded as NOT APPLICABLE.

  // ===== (7) inside a GENERATE for-loop — the tlul container ==============
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : g_blk
      // genvar base index + compound trailing part-select: the tl_h_i shape
      assign o[52+gi] = tl_h_i[gi].a_source[0+:(FromPkg-FromClog)] != 0;
      // genvar in a COMPOUND index — does a genvar reduce when compound?
      assign o[54+gi] = tl_h_i[gi+1].a_source[0];
      // module localparam, bare, base, inside a gen scope
      assign o[56+gi] = arr[LocLp].base.q[0];
    end
  endgenerate

endmodule

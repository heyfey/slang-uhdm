// r10earl40 arm a1 — THE POLICY GRID for a SELECT written on a PACKAGE-SCOPED
// name inside a DEF-VIEW GENERATE cont-assign.
//
// The head (Earlgrey prim_prince.sv:105-106) is
//     assign data_state_xor = data_state_round ^
//                             prim_cipher_pkg::PRINCE_ROUND_CONST[k][DataWidth-1:0];
// where PRINCE_ROUND_CONST is a PACKAGE PARAMETER of packed type
// `logic [11:0][63:0]`, `k` is the enclosing GENVAR and `DataWidth` a module
// parameter.  This file crosses the axes the brief named:
//
//   BASE SCOPE   package-scoped (p40::ARR40)  vs  module-local (loc40)
//   SELECT SHAPE bit only / range only / bit+range / bit+bit / indexed-range
//                / bit+bit+range  / NO SELECT AT ALL
//   INDEX KIND   genvar / module param / localparam / literal / expression
//   CONTEXT      def-view gen-for CA (the head) / gen-if CA / nested gen CA
//                / gen-for PROCESS / module-level CA / module-level process
//
// Cell naming: every target net is `c_<cell>` so a span-keyed census can name
// the cell from the dump without a line table.
//
// THE CONTROLS THAT MATTER MOST are the NO-SELECT cells (n1/n2) — a bare
// package name must stay a plain ref_obj and must NOT be dragged into a
// var_select by any predicate written here.

package p40;
  parameter int W40 = 64;
  parameter logic [11:0][63:0] ARR40 = {12{64'hC0AC29B7C97C50DD}};
  parameter logic [7:0]        FLAT40 = 8'hA5;
  parameter logic [3:0][7:0]   SM40  = {8'h1, 8'h2, 8'h3, 8'h4};
endpackage

module a1_sel40 #(
  parameter int DataWidth = 64,
  parameter int NRound    = 3
) (
  input  logic [63:0] in40,
  output logic [63:0] out40
);

  localparam int LP40 = 2;

  logic [11:0][63:0] loc40;
  assign loc40 = p40::ARR40;

  // ---------------------------------------------------------------- module CA
  // Module-level cont-assigns.  These do NOT go through the def-view generate
  // emitter, so they are HOLD cells: whatever they are in PRISTINE they must
  // stay in PATCHED.
  logic [63:0] c_mca_pkg_br;
  assign c_mca_pkg_br = p40::ARR40[0][DataWidth-1:0];   // pkg, bit+range
  logic [63:0] c_mca_pkg_b;
  assign c_mca_pkg_b  = p40::ARR40[1];                  // pkg, bit only
  logic [3:0]  c_mca_pkg_r;
  assign c_mca_pkg_r  = p40::FLAT40[3:0];               // pkg, range only
  logic [63:0] c_mca_loc_br;
  assign c_mca_loc_br = loc40[0][DataWidth-1:0];        // LOCAL, bit+range
  logic [31:0] c_mca_pkg_nos;
  assign c_mca_pkg_nos = p40::W40;                      // NO SELECT — HOLD

  // ------------------------------------------------------------ module PROCESS
  // The exact shape of prim_prince.sv:81 (`p_pre_round_xor`), which is a
  // MODULE-LEVEL always_comb naming the same package array with a LITERAL
  // index.  Emitted from the bound AST (emitExpr), not from syntax.
  logic [63:0] c_mpr_pkg_br;
  always_comb begin : p_mpr40
    c_mpr_pkg_br = in40;
    c_mpr_pkg_br ^= p40::ARR40[0][DataWidth-1:0];
  end

  // ------------------------------------------------------- def-view gen-for CA
  // THE HEAD'S OWN CONTEXT.  Every cont-assign in this body is emitted twice:
  // once into the DEFINITION listing from SYNTAX (emitSyntaxExpr) and once into
  // the ELABORATED gen_scope from the bound AST.  Both listings are censused.
  for (genvar k = 1; k <= NRound; k++) begin : gen_f40
    logic [63:0] c_gca_pkg_bk_rsym;
    assign c_gca_pkg_bk_rsym = p40::ARR40[k][DataWidth-1:0];   // *** THE HEAD ***

    logic [63:0] c_gca_pkg_blit_rsym;
    assign c_gca_pkg_blit_rsym = p40::ARR40[0][DataWidth-1:0]; // literal bit

    logic [63:0] c_gca_pkg_bk_rlit;
    assign c_gca_pkg_bk_rlit = {32'h0, p40::ARR40[k][31:0]};   // literal range

    logic [63:0] c_gca_pkg_blit_rlit;
    assign c_gca_pkg_blit_rlit = {32'h0, p40::ARR40[1][31:0]}; // both literal

    logic [63:0] c_gca_pkg_bexpr_rsym;
    assign c_gca_pkg_bexpr_rsym = p40::ARR40[k-1][DataWidth-1:0]; // EXPR index

    logic [63:0] c_gca_pkg_bparam_rsym;
    assign c_gca_pkg_bparam_rsym = p40::ARR40[LP40][DataWidth-1:0]; // localparam

    // ---- single-selector cells: must NOT become a var_select
    logic [63:0] c_gca_pkg_bonly_k;
    assign c_gca_pkg_bonly_k = p40::ARR40[k];                  // bit only
    logic [63:0] c_gca_pkg_bonly_lit;
    assign c_gca_pkg_bonly_lit = p40::ARR40[2];                // bit only, lit
    logic [3:0]  c_gca_pkg_ronly;
    assign c_gca_pkg_ronly = p40::FLAT40[3:0];                 // range only
    logic [7:0]  c_gca_pkg_ronly_sym;
    assign c_gca_pkg_ronly_sym = p40::FLAT40[DataWidth-57:0];  // range only, sym

    // ---- two BIT selects (no range at all)
    logic [7:0]  c_gca_pkg_bb;
    assign c_gca_pkg_bb = p40::SM40[k-1][7:0];                 // bit + range 8b
    logic        c_gca_pkg_bbit;
    assign c_gca_pkg_bbit = p40::ARR40[k][0];                  // bit + bit

    // ---- INDEXED part select
    logic [7:0]  c_gca_pkg_bidx;
    assign c_gca_pkg_bidx = p40::ARR40[k][DataWidth-1 -: 8];   // bit + -:
    logic [7:0]  c_gca_pkg_bidxa;
    assign c_gca_pkg_bidxa = p40::ARR40[k][0 +: 8];            // bit + +:

    // ---- NO SELECT AT ALL — the two cells that must never move
    logic [31:0] c_gca_pkg_nosel;
    assign c_gca_pkg_nosel = p40::W40;                         // bare pkg param
    logic [11:0][63:0] c_gca_pkg_whole;
    assign c_gca_pkg_whole = p40::ARR40;                       // whole array

    // ---- LOCAL (bare-base) twins of the head: the EXISTING var_select arm
    logic [63:0] c_gca_loc_bk_rsym;
    assign c_gca_loc_bk_rsym = loc40[k][DataWidth-1:0];
    logic [63:0] c_gca_loc_bonly;
    assign c_gca_loc_bonly = loc40[k];

    // ---- a def-view gen PROCESS naming the same thing (different emitter)
    logic [63:0] c_gpr_pkg_bk_rsym;
    always_comb begin : p_gpr40
      c_gpr_pkg_bk_rsym = in40;
      c_gpr_pkg_bk_rsym ^= p40::ARR40[k][DataWidth-1:0];
    end

    // ---- NESTED gen-if inside the gen-for: does the prefix double again?
    if (DataWidth == 64) begin : gen_n40
      logic [63:0] c_gif_pkg_bk_rsym;
      assign c_gif_pkg_bk_rsym = p40::ARR40[k][DataWidth-1:0];
      logic [63:0] c_gif_loc_bk_rsym;
      assign c_gif_loc_bk_rsym = loc40[k][DataWidth-1:0];
    end else begin : gen_n40e
      logic [63:0] c_gife_pkg_bk_rsym;
      assign c_gife_pkg_bk_rsym = p40::ARR40[k][DataWidth-1:0];
    end
  end

  // ------------------------------------------------- def-view gen-if (top) CA
  if (DataWidth == 64) begin : gen_t40
    logic [63:0] c_gift_pkg_blit_rsym;
    assign c_gift_pkg_blit_rsym = p40::ARR40[0][DataWidth-1:0];
    logic [63:0] c_gift_pkg_nosel;
    assign c_gift_pkg_nosel = {32'h0, p40::W40};
  end

  assign out40 = c_mca_pkg_br ^ c_mpr_pkg_br ^ c_mca_loc_br;

endmodule

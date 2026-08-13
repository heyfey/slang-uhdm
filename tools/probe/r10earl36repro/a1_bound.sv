// r10earl36 a1 — THE SEPARATING GRID for a DECLARATION-CARRIED packed-dim
// RANGE BOUND on a NAMED (package struct) element type, i.e. the
// packed_array_typespec carrier, crossed against the plain-vector
// (logic_typespec) carrier that § shadowedImportBoundFold already serves.
//
// Axes:
//   * carrier      : q36::f_t [B] (packed_array_typespec) vs logic [B] (logic_typespec)
//   * bound symbol : module parameter / module localparam / package localparam /
//                    package parameter / UNTYPED package localparam
//   * SHADOWING    : does the module declare the SAME NAME the wildcard-imported
//                    package also declares?  (the corpus discriminator:
//                    flash_mp's `NumBanks` is BOTH a module parameter and a
//                    flash_ctrl_pkg localparam; `TotalRegions` is module-only)
//   * bound form   : `X-1` operation / plain `X` / `$clog2(X)-1` / literal
//   * depth        : one dim / two dims
//   * position     : port / body net
//   * import site  : module BODY (this file, exactly like flash_mp.sv:51)
//
// The values are chosen so the PACKAGE member and the MODULE declaration
// DISAGREE — every cell's constant names which side Surelog resolved.
package q36;
  localparam int SH_P    = 5;   // twin of the module PARAMETER  SH_P    (mod 9)
  localparam int SH_LP   = 7;   // twin of the module LOCALPARAM SH_LP   (mod 9)
  parameter  int SH_PP   = 6;   // a package PARAMETER, twin of module SH_PP (9)
  localparam     SH_IMPL = 4;   // UNTYPED package localparam, twin of SH_IMPL (9)
  localparam int ONLY_PK = 3;   // package-only name (no module twin)
  typedef struct packed { logic q; } f_t;
endpackage

module m36 #(
  parameter  int SH_P    = 9,
  parameter  int SH_PP   = 9,
  parameter  int SH_IMPL = 9,
  parameter  int NOCOLL  = 4,
  localparam int SH_LP   = 9,
  localparam int LOCONLY = 4
) (
  input logic clk_i,

  // ---- A. packed_array_typespec carrier (named pkg type + declaration dim) --
  input q36::f_t [SH_P-1:0]            a_shp,       // THE WITNESS (flash_mp:22)
  input q36::f_t [SH_PP-1:0]           a_shpp,
  input q36::f_t [SH_IMPL-1:0]         a_shimpl,
  input q36::f_t [SH_LP-1:0]           a_shlp,
  input q36::f_t [NOCOLL-1:0]          a_nocoll,    // module param, NO twin
  input q36::f_t [LOCONLY-1:0]         a_loconly,   // module lp, NO twin (:21)
  input q36::f_t [SH_P:0]              a_shp_plain, // plain-ident bound
  input q36::f_t [q36::ONLY_PK-1:0]    a_qual,      // written QUALIFIED
  input q36::f_t [$clog2(SH_P)-1:0]    a_clog,      // sys-call bound
  input q36::f_t [SH_P-1:0][NOCOLL-1:0] a_two,      // two dims
  input q36::f_t [3:0]                 a_lit,       // literal bound
  output logic [SH_P-1:0]              a_out,

  // ---- B. logic_typespec carrier (the already-serving reference cells) ------
  input logic [SH_P-1:0]               b_shp,
  input logic [SH_LP-1:0]              b_shlp,
  input logic [SH_IMPL-1:0]            b_shimpl,
  input logic [NOCOLL-1:0]             b_nocoll,
  input logic [LOCONLY-1:0]            b_loconly,
  output logic                         o_o
);
  // exactly flash_mp.sv:51 — the wildcard import lives in the module BODY,
  // AFTER the port list whose bounds it decides.
  import q36::*;

  // ---- C. BODY nets, same two carriers, plus the package-ONLY names that
  //         are only visible after the import ------------------------------
  q36::f_t [SH_P-1:0]   c_shp;
  q36::f_t [NOCOLL-1:0] c_nocoll;
  q36::f_t [ONLY_PK-1:0] c_onlypk;      // pkg-only, bare (import is above)
  logic    [SH_P-1:0]   c_bshp;
  logic    [ONLY_PK-1:0] c_bonlypk;

  assign o_o = clk_i;
  assign a_out = '0;
  assign c_shp = '0;
  assign c_nocoll = '0;
  assign c_onlypk = '0;
  assign c_bshp = '0;
  assign c_bonlypk = '0;
endmodule

// A TOP that instantiates m36, so the DEF view (the module listing) and the
// ELAB view (the instance) are both present — flash_mp is an INSTANCE, and a
// top-only module takes a different, single-view path in our emitter.
module top36;
  logic clk;
  logic o;
  m36 u36 (.clk_i(clk), .o_o(o), .a_shp(), .a_shpp(), .a_shimpl(), .a_shlp(),
           .a_nocoll(), .a_loconly(), .a_shp_plain(), .a_qual(), .a_clog(),
           .a_two(), .a_lit(), .a_out(), .b_shp(), .b_shlp(), .b_shimpl(),
           .b_nocoll(), .b_loconly());
endmodule

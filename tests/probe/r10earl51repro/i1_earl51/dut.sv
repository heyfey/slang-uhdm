// i1 — r10earl51's FIRST cut at R0, the Earlgrey_0_1/default 52-line head
//
//     sram2tlul.sv:42   assign tl_o.a_size = top_pkg::TL_SZW'(SRAM_DWB);
//     with              localparam int unsigned SRAM_DWB = $clog2(SramDw/8);
//     and               SramDw a MODULE PARAMETER.
//
// r10earl50 measured two cells and read them as one answer:
//   h6.o1  `assign o1 = h6p::SZW'(DWB);`      DWB = $clog2(32/8)     -> golden FOLDS
//   h7     `assign tl_o.a_size = h7p::TL_SZW'(SRAM_DWB);`
//                                             SRAM_DWB = $clog2(SramDw/8)
//                                                                    -> golden KEEPS the op
// and concluded "the struct-member LHS is not it" because our side ACCIDENTALLY
// matched h7 (we SHARE the def cont_assign there, because `tl_o` elaborates to
// a struct_NET in h7 and to a struct_VAR in Earlgrey).  Two features move
// between those two cells at once.  This arm crosses them.
//
// AXES, one cell per crossing:
//   * the enclosing module HAS a parameter, or has none
//   * the LHS is a plain net, or a MEMBER of a packed-struct output
//   * the cast OPERAND is: a localparam folded from LITERALS, a localparam
//     folded through a MODULE PARAMETER, a plain `= 2` localparam, or the
//     module PARAMETER itself
package i1p;
  parameter int unsigned SZW = 2;
  typedef struct packed {
    logic [1:0] m1;
    logic [1:0] m2;
    logic [1:0] m3;
    logic [1:0] m4;
  } st_t;
endpackage

// ---- (A) a module with NO parameters at all --------------------------------
module i1_noparam (
  output logic [1:0] a1,
  output logic [1:0] a2,
  output i1p::st_t   s
);
  localparam int unsigned A_LIT = $clog2(32/8);   // folded from literals
  localparam int unsigned A_PLN = 2;              // plain

  assign a1   = i1p::SZW'(A_LIT);
  assign a2   = i1p::SZW'(A_PLN);
  assign s.m1 = i1p::SZW'(A_LIT);
  assign s.m2 = i1p::SZW'(A_PLN);
endmodule

// ---- (B) a module WITH a parameter -----------------------------------------
module i1_param #(
  parameter int SramDw = 32
) (
  output logic [1:0] b1,
  output logic [1:0] b2,
  output logic [1:0] b3,
  output i1p::st_t   t
);
  localparam int unsigned B_PAR = $clog2(SramDw/8);  // through the parameter
  localparam int unsigned B_LIT = $clog2(32/8);      // from literals
  localparam int unsigned B_PLN = 2;                 // plain

  assign b1   = i1p::SZW'(B_PAR);
  assign b2   = i1p::SZW'(B_LIT);
  assign b3   = i1p::SZW'(B_PLN);
  assign t.m1 = i1p::SZW'(B_PAR);
  assign t.m2 = i1p::SZW'(B_LIT);
  assign t.m3 = i1p::SZW'(B_PLN);
  assign t.m4 = i1p::SZW'(SramDw);
endmodule

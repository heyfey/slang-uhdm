// r10earl86 g2 — LEAF KINDS x UNARY OPERATOR SPANS x TYPESPEC PRESENCE.
// Same carrier as g1: `~(('h1 << <SUB>) - 1'b1)`.  GOLDEN = Surelog.
package q86b_pkg;
  parameter int PKGP = 3;
  localparam int PKGQ = 6;
endpackage

module m86_lv #(parameter int AddrW = 17) ();
  import q86b_pkg::*;
  localparam int P = 8;
  localparam int W = 5;
  localparam logic [7:0] LW = 8'd3;
  localparam bit [7:0] BW = 8'd6;
  localparam byte BY = 8'd7;
  localparam integer IG = 9;
  localparam shortint SI = 11;
  localparam longint LI = 12;
  localparam signed [7:0] SG = 8'sd13;
  localparam BARE = 4;

  // --- UNARY over each leaf kind (size comes from the OPERAND) -------------
  localparam logic[AddrW-1:0] v_ngP  = ~(('h1 << (~P)) - 1'b1);
  localparam logic[AddrW-1:0] v_ngLW = ~(('h1 << (~LW)) - 1'b1);
  localparam logic[AddrW-1:0] v_ngBW = ~(('h1 << (~BW)) - 1'b1);
  localparam logic[AddrW-1:0] v_ngBY = ~(('h1 << (~BY)) - 1'b1);
  localparam logic[AddrW-1:0] v_ngIG = ~(('h1 << (~IG)) - 1'b1);
  localparam logic[AddrW-1:0] v_ngSI = ~(('h1 << (~SI)) - 1'b1);
  localparam logic[AddrW-1:0] v_ngLI = ~(('h1 << (~LI)) - 1'b1);
  localparam logic[AddrW-1:0] v_ngSG = ~(('h1 << (~SG)) - 1'b1);
  localparam logic[AddrW-1:0] v_ngBR = ~(('h1 << (~BARE)) - 1'b1);
  localparam logic[AddrW-1:0] v_ngLT = ~(('h1 << (~8'd3)) - 1'b1);
  localparam logic[AddrW-1:0] v_ngUL = ~(('h1 << (~7)) - 1'b1);
  localparam logic[AddrW-1:0] v_ngPK = ~(('h1 << (~PKGP)) - 1'b1);
  localparam logic[AddrW-1:0] v_ngQL = ~(('h1 << (~q86b_pkg::PKGQ)) - 1'b1);
  localparam logic[AddrW-1:0] v_ngSB = ~(('h1 << (~(P + W))) - 1'b1);

  // --- MINUS over each leaf kind (size = the operand's) --------------------
  localparam logic[AddrW-1:0] v_mnP  = ~(('h1 << (-P)) - 1'b1);
  localparam logic[AddrW-1:0] v_mnLW = ~(('h1 << (-LW)) - 1'b1);
  localparam logic[AddrW-1:0] v_mnLI = ~(('h1 << (-LI)) - 1'b1);
  localparam logic[AddrW-1:0] v_mnUL = ~(('h1 << (-7)) - 1'b1);
  localparam logic[AddrW-1:0] v_mnSB = ~(('h1 << (-(P + W))) - 1'b1);

  // --- TWO-CHARACTER UNARY OPERATORS (the span is the OPERATOR token) ------
  localparam logic[AddrW-1:0] v_nand = ~(('h1 << (~&LW)) - 1'b1);
  localparam logic[AddrW-1:0] v_nor  = ~(('h1 << (~|LW)) - 1'b1);
  localparam logic[AddrW-1:0] v_xnor = ~(('h1 << (~^LW)) - 1'b1);

  // --- BINARY: the ADD sign rule, over each leaf kind ----------------------
  localparam logic[AddrW-1:0] v_aPW  = ~(('h1 << (P + W)) - 1'b1);
  localparam logic[AddrW-1:0] v_aPL  = ~(('h1 << (P + LW)) - 1'b1);
  localparam logic[AddrW-1:0] v_aPB  = ~(('h1 << (P + BW)) - 1'b1);
  localparam logic[AddrW-1:0] v_aPY  = ~(('h1 << (P + BY)) - 1'b1);
  localparam logic[AddrW-1:0] v_aPG  = ~(('h1 << (P + IG)) - 1'b1);
  localparam logic[AddrW-1:0] v_aPI  = ~(('h1 << (P + SI)) - 1'b1);
  localparam logic[AddrW-1:0] v_aPJ  = ~(('h1 << (P + LI)) - 1'b1);
  localparam logic[AddrW-1:0] v_aPS  = ~(('h1 << (P + SG)) - 1'b1);
  localparam logic[AddrW-1:0] v_aPR  = ~(('h1 << (P + BARE)) - 1'b1);
  localparam logic[AddrW-1:0] v_aPD  = ~(('h1 << (P + 8'd3)) - 1'b1);
  localparam logic[AddrW-1:0] v_aPU  = ~(('h1 << (P + 7)) - 1'b1);
  localparam logic[AddrW-1:0] v_aPH  = ~(('h1 << (P + 8'h3)) - 1'b1);
  localparam logic[AddrW-1:0] v_aPK  = ~(('h1 << (P + PKGP)) - 1'b1);
  localparam logic[AddrW-1:0] v_aPQ  = ~(('h1 << (P + q86b_pkg::PKGQ)) - 1'b1);
  localparam logic[AddrW-1:0] v_aPN  = ~(('h1 << (P + (W + 1))) - 1'b1);
  localparam logic[AddrW-1:0] v_aSP  = ~(('h1 << ((P + W) + 1)) - 1'b1);

  // --- SUB / MUL over parenthesised left operands -------------------------
  localparam logic[AddrW-1:0] v_sPR  = ~(('h1 << ((P + W) - 2)) - 1'b1);
  localparam logic[AddrW-1:0] v_mPR  = ~(('h1 << ((P + W) * 2)) - 1'b1);
  localparam logic[AddrW-1:0] v_dPR  = ~(('h1 << ((P + W) / 2)) - 1'b1);
endmodule

module top86_lv ();
  m86_lv #(.AddrW(17)) i0 ();
endmodule

// --- r10earl86 APPENDIX: the IMPLICIT-SIGNING split -------------------------
// `signed [7:0]` and `signed` are BOTH ImplicitType in slang and BOTH compile
// to a SIGNED int_typespec in Surelog; an untyped `X = 4` compiles to an
// UNSIGNED one.  § valueRangeImplicitSigning86 turns on exactly that keyword.
module m86_sgn #(parameter int AddrW = 17) ();
  localparam signed [7:0] S_RNG = 8'sd13;
  localparam signed       S_BAR = 13;
  localparam unsigned[7:0] S_UNS = 8'd13;
  localparam              S_IMP = 13;
  localparam logic [7:0]  S_LOG = 8'd13;
  localparam int          S_INT = 13;
  localparam logic signed [7:0] S_LSG = 8'sd13;
  localparam bit signed [7:0]   S_BSG = 8'sd13;

  localparam logic[AddrW-1:0] s_rng = ~(('h1 << (S_RNG + 1)) - 1'b1);
  localparam logic[AddrW-1:0] s_bar = ~(('h1 << (S_BAR + 1)) - 1'b1);
  localparam logic[AddrW-1:0] s_uns = ~(('h1 << (S_UNS + 1)) - 1'b1);
  localparam logic[AddrW-1:0] s_imp = ~(('h1 << (S_IMP + 1)) - 1'b1);
  localparam logic[AddrW-1:0] s_log = ~(('h1 << (S_LOG + 1)) - 1'b1);
  localparam logic[AddrW-1:0] s_int = ~(('h1 << (S_INT + 1)) - 1'b1);
  localparam logic[AddrW-1:0] s_lsg = ~(('h1 << (S_LSG + 1)) - 1'b1);
  localparam logic[AddrW-1:0] s_bsg = ~(('h1 << (S_BSG + 1)) - 1'b1);
  // and the same leaves read BARE, so the leaf itself is visible (the `^`
  // carrier has no reduceExpr arm, so golden keeps the operation and shows it).
  localparam logic[AddrW-1:0] x_rng = ~(('h1 << (S_RNG ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] x_bar = ~(('h1 << (S_BAR ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] x_uns = ~(('h1 << (S_UNS ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] x_imp = ~(('h1 << (S_IMP ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] x_log = ~(('h1 << (S_LOG ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] x_int = ~(('h1 << (S_INT ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] x_lsg = ~(('h1 << (S_LSG ^ 1)) - 1'b1);
  localparam logic[AddrW-1:0] x_bsg = ~(('h1 << (S_BSG ^ 1)) - 1'b1);
endmodule

module top86_sgn ();
  m86_sgn #(.AddrW(17)) i0 ();
endmodule

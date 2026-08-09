// wc.sv — PASS 14 round 2, the flash_phy_pkg:43 TERNARY import copy.
// After § impModFoldSigned the flash_phy_rd / flash_phy_rd_buffers heads
// advanced to `parameter int WordSelW = WidthMultiple == 1 ? 1 : LsbAddrBit`:
// golden's DEF module listing folds the copy to the TAKEN BRANCH's constant
// AT THE BRANCH LEAF'S SPAN (43:53 = the `LsbAddrBit` token), where we keep
// the whole ternary operation at 43:28.  The sibling head (flash_phy_core,
// which HAS a parameter port list and so takes the def->elab shape FLIP)
// already folds it and is missing only the constant's ref_typespec.
// The 2x2 is therefore module SHAPE x branch LEAF KIND:
//   wcnp  no parameter port list   (flash_phy_rd shape)
//   wcpp  WITH a parameter port list (flash_phy_core shape)
//   T1    taken branch = a PARAMETER reference (flash_phy_pkg:43 exactly)
//   T2    taken branch = a LITERAL
//   T3    condition TRUE, so the FIRST branch is taken (span moves left)
//   T4    a non-ternary control (plain `/`) — must stay as pass 14 round 1
package wcp;
  parameter int WM = 2;
  parameter int LB = $clog2(WM);
  parameter int T1 = WM == 1 ? 1 : LB;
  parameter int T2 = WM == 1 ? 1 : 7;
  parameter int T3 = WM == 2 ? LB : 9;
  parameter int T4 = WM / 2;
  // T5/T6 — round 3: is the DEF-copy signedness of a TERNARY decided by the
  // TAKEN BRANCH's own operator (the § impArithFoldSigned rule one level in)?
  // `-` must give INT and `+` UINT if the branch is what ExprEval reduces.
  parameter int T5 = WM == 1 ? 1 : LB - 1;
  parameter int T6 = WM == 1 ? 1 : LB + 1;
endpackage

module wcnp import wcp::*; (
  input logic clk_i
);
  logic [T1:0] t1_n;
endmodule

module wcpp import wcp::*; #(
  parameter bit SkipInit = 1
) (
  input logic clk_i
);
  logic [T1:0] t1_n;
endmodule

module wctop;
  logic c;
  wcnp u0(.clk_i(c));
  wcpp u1(.clk_i(c));
endmodule

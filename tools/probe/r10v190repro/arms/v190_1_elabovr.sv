// r10v190 arm 1 — THE ELABORATION FACE.
// The patch unbinds the enum-base clone's range reference in BOTH views.  In
// the ELABORATED view Surelog deep-clones a module's contents with a LIVE
// binder (`ref_obj::DeepCopy` -> `m_elaborator.bindAny(VpiName())`), so an
// elaborated clone COULD legitimately carry a `vpiActual` that the definition
// view lacks.  If it does, the pass's unconditional unbind is a REGRESSION.
//
// Cells: a module parameter read by an enum-base typedef, instantiated
//   1a default (no override)
//   1b overridden by value
//   1c overridden by an expression over the parent's own parameter
//   1d twice with DIFFERENT overrides (two elaborated copies of one definition)
// plus a package parameter overridden nowhere, for contrast.
package pv1_190;
  parameter integer PKW = 9;
  typedef bit [PKW-1 : 0] tp1;
  typedef enum tp1 { p1_a = 0, p1_b = 1 } ep1;
endpackage

module leaf190 #(parameter integer LW = 7) (input logic clk);
  typedef bit [LW-1 : 0]  tl1;               // the ranged typedef
  typedef enum tl1 { l1_a = 0, l1_b = 1 } el1;   // enum base clone
  typedef logic [LW+1 : 2] tl2;
  typedef enum tl2 { l2_a = 0, l2_b = 1 } el2;
  tl1 raw;
  el1 e1;
  el2 e2;
  pv1_190::ep1 e3;
  always_comb begin
    raw = '0;
    e1  = l1_a;
    e2  = l2_b;
    e3  = pv1_190::p1_b;
  end
endmodule

module v190_1_elabovr (input logic clk);
  parameter integer TOPW = 5;
  leaf190              u_def  (.clk(clk));            // 1a default
  leaf190 #(.LW(13))   u_ovr  (.clk(clk));            // 1b value override
  leaf190 #(.LW(TOPW*2)) u_expr(.clk(clk));           // 1c expression override
  leaf190 #(.LW(21))   u_two  (.clk(clk));            // 1d second override
endmodule

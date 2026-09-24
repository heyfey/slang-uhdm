// r10earl42 OVER-FIRE / UNDER-FIRE PROBE for § importedConcatNoMdimReorder42.
//
// The gate is `!isImported`, and `isImported` is a PER-PARAMETER property
// (`ps.getParentScope() != &body`), NOT a per-scope one.  This probe puts BOTH
// kinds in the SAME module: a wildcard-imported package localparam and the
// module's OWN localparam, with the IDENTICAL type and the IDENTICAL concat.
// If the gate were read as "this scope imports something", the own-declared
// E1_MIX_OWN would stop reordering and the pass would silently UNDER-fire.
//
// GOLDEN, elaborated listing (measured, not assumed):
//   E0_PKG_CC (imported copy)  source order, NO vpiReordered
//   E1_MIX_OWN (own localparam) REVERSED + vpiReordered
//
// LHS is ALWAYS golden (Surelog).

package p42v;
  localparam logic [3:0][31:0] E0_PKG_CC = {
    32'h 40000000,
    32'h 40080000,
    32'h 400a0000,
    32'h 40150000
  };
  localparam logic [31:0] E2_R0 = 32'h 11110000;
  localparam logic [31:0] E2_R1 = 32'h 22220000;
  localparam logic [3:0][31:0] E2_PKG_CR = {E2_R0, E2_R1, E2_R0, E2_R1};
endpackage

module mixed42 (input logic clk, output logic [31:0] o);
  import p42v::*;

  // the module's OWN localparam, same type, same concat shape
  localparam logic [3:0][31:0] E1_MIX_OWN = {
    32'h 50000000,
    32'h 50080000,
    32'h 500a0000,
    32'h 50150000
  };

  assign o = E0_PKG_CC[0] ^ E1_MIX_OWN[0] ^ E2_PKG_CR[0] ^ {32{clk}};
endmodule

module topv42 (input logic clk, output logic [31:0] o);
  mixed42 u_mix (.clk(clk), .o(o));
endmodule

// qc28.sv -- pass-28 grid #3, THE DISCRIMINATOR GRID.  ParamEmit's ovEnc8
// (the "producer/consumer" two-stage model, measured over a 238-cell matrix)
// recurses through NamedValue / UnbasedUnsized / Concat / Replication but has
// NO ConditionalExpression arm, so the corpus chain falls through to the
// decimal UINT fold.  Its comment states each parameter-ref HOP re-runs
// adjustSize with THAT parameter's own typespec ("`int P = 8'hab` decompiles
// 32'hab one instance down while an untyped `P = 8'hab` stays 8'hab").
// qb28 measured golden giving BIN 1'b1 size 1 for `int FifoPass = C ? 1'b0 :
// 1'b1` one AND two instances down -- NOT the INT:-1 size 32 that the `int`
// hop's adjustSize would produce, and NOT what FifoPass's OWN elaborated value
// reads (golden: INT size 32 dec -1).
// SO THE QUESTION THIS FILE ANSWERS, and nothing in the tree measures it:
//   does a TERNARY source SKIP the intermediate hop's adjustSize that a
//   DIRECT LITERAL source runs?
// EVERY PAIR IS (direct literal | same literal behind a taken ternary) with
// the SAME declared types and the SAME override chain, so the two rows differ
// in the ternary and nothing else.  LHS(golden) / RHS(ours) as always.

module snk28 #(
  parameter int          TI  = 8'h1,   // int (SIGNED)      -- the adjust arm
  parameter int unsigned TU  = 8'h1,   // int unsigned      -- BIN survives
  parameter bit          TB  = 1'b1,   // bit               -- corpus target
  parameter logic [7:0]  TL  = 8'h1    // logic [7:0]
) (
  input  logic clk_i,
  output logic o
);
  assign o = clk_i ^ TI[0] ^ TU[0] ^ TB ^ TL[0];
endmodule

module hop28 #(
  parameter int          HI = 8'h1,    // the `int P = 8'hab` hop of the comment
  parameter int unsigned HU = 8'h1,
  parameter bit          HB = 1'b1
) (
  input  logic clk_i,
  output logic o
);
  snk28 #(.TI(HI), .TU(HU), .TB(HB), .TL(HI)) u_t (.clk_i, .o);
endmodule

module qc28 #(
  parameter bit C = 1'b0
) (
  input  logic clk_i,
  output logic o1, o2, o3, o4, o5, o6, o7, o8
);
  // --- WIDE (8-bit) literal, so the hop adjust is VISIBLE as 8'hab -> 32'hab
  localparam int DirWide  = 8'hab;             // direct
  localparam int TerWide  = C ? 8'hcd : 8'hab; // same value behind a ternary

  // --- 1-BIT literal, the corpus's own width
  localparam int DirBit   = 1'b1;
  localparam int TerBit   = C ? 1'b0 : 1'b1;   // rv_core_ibex.sv:67 verbatim

  // --- ternary whose CONDITION is a comparison, not a bare param ref
  localparam int CmpBit   = (C == 1'b1) ? 1'b0 : 1'b1;

  // --- ternary NESTED two deep
  localparam int NestBit  = C ? 1'b0 : (C ? 1'b0 : 1'b1);

  // --- ternary source read through ONE MORE localparam hop before the port
  localparam int ViaLp    = TerBit;

  // one instantiation per source: chain is qc28 -> hop28 -> snk28, i.e. the
  // corpus's TWO override hops.
  hop28 #(.HI(DirWide), .HU(DirWide), .HB(DirWide)) u_dw (.clk_i, .o(o1));
  hop28 #(.HI(TerWide), .HU(TerWide), .HB(TerWide)) u_tw (.clk_i, .o(o2));
  hop28 #(.HI(DirBit),  .HU(DirBit),  .HB(DirBit))  u_db (.clk_i, .o(o3));
  hop28 #(.HI(TerBit),  .HU(TerBit),  .HB(TerBit))  u_tb (.clk_i, .o(o4));
  hop28 #(.HI(CmpBit),  .HU(CmpBit),  .HB(CmpBit))  u_cb (.clk_i, .o(o5));
  hop28 #(.HI(NestBit), .HU(NestBit), .HB(NestBit)) u_nb (.clk_i, .o(o6));
  hop28 #(.HI(ViaLp),   .HU(ViaLp),   .HB(ViaLp))   u_vl (.clk_i, .o(o7));

  // and the ternary written DIRECTLY as the override actual, no localparam
  hop28 #(.HI(C ? 1'b0 : 1'b1), .HU(C ? 1'b0 : 1'b1),
          .HB(C ? 1'b0 : 1'b1)) u_dt (.clk_i, .o(o8));
endmodule

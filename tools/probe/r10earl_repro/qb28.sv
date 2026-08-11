// qb28.sv -- pass-28 grid #2.  qa28 found the CORPUS CHAIN, and the chain's
// source is a TERNARY, not a plain literal:
//   rv_core_ibex.sv:67  `localparam int FifoPass = PipeLine ? 1'b0 : 1'b1;`
//   rv_core_ibex.sv:225 `.ReqPass(FifoPass)`  -> tlul_fifo_sync's
//   `parameter int unsigned ReqPass = 1'b1` -> `.Pass(ReqPass)` ->
//   prim_fifo_sync.sv:11 `parameter bit Pass = 1'b1`.
// FRONTIER, LHS(golden) / RHS(ours):
//   constant @prim_fifo_sync.sv:11:40  {ct=3 BIN sz=1 dec=1'b1} / {ct=9 UINT
//   sz=1 dec=1}
// qa28 PROVED the override spelling propagates from the SOURCE, not the
// default (a `bit LD = 1` overridden from a `1'b1` source reads BIN 1'b1 on
// BOTH sides), so the only unmeasured link left is what a CONSTANT-CONDITION
// TERNARY reduces to.
// AXES: taken-branch base (1'b1 / 1 / 4'h2 / 2'd1) x which branch is taken
// (then / else) x declared type of the folding localparam (int / bit /
// logic[3:0]) x scope (module localparam / package parameter).

package pq28;
  parameter bit CondP = 1'b0;
  // package-scope taken-branch ternaries
  parameter int          QA = CondP ? 1'b0 : 1'b1;   // else taken, BIN
  parameter int          QB = CondP ? 1     : 4'h2;  // else taken, HEX
  parameter logic [3:0]  QC = CondP ? 4'h2 : 4'h0;   // else taken, HEX
endpackage

module sink28 #(
  parameter bit          SB = 1'b1,   // bit,          exactly prim_fifo_sync
  parameter int unsigned SI = 1'b1,   // int unsigned, exactly tlul_fifo_sync
  parameter logic [3:0]  SL = 4'h1
) (
  input  logic clk_i,
  output logic o
);
  assign o = clk_i ^ SB ^ SI[0] ^ SL[0];
endmodule

// the middle hop, so the chain has the corpus's TWO levels of override
module mid28b #(
  parameter int unsigned MB = 1'b1,
  parameter int unsigned MI = 1'b1,
  parameter int unsigned ML = 4'h1
) (
  input  logic clk_i,
  output logic o
);
  sink28 #(.SB(MB), .SI(MI), .SL(ML)) u_s (.clk_i, .o);
endmodule

module qb28 #(
  parameter bit PipeLine = 1'b0        // exactly rv_core_ibex's discriminator
) (
  input  logic clk_i,
  output logic oa,
  output logic ob,
  output logic oc,
  output logic od,
  output logic oe
);
  // A: the corpus source, verbatim
  localparam int FifoPass  = PipeLine ? 1'b0 : 1'b1;
  // B: same shape, THEN branch taken
  localparam int TakeThen  = !PipeLine ? 1'b1 : 1'b0;
  // C: based-hex branches
  localparam int FifoDepth = PipeLine ? 4'h2 : 4'h0;
  // D: an UNSIZED branch, the negative control
  localparam int PlainDec  = PipeLine ? 0 : 1;
  // E: a bit-typed folding localparam rather than int
  localparam bit BitPass   = PipeLine ? 1'b0 : 1'b1;

  mid28b #(.MB(FifoPass),  .MI(FifoPass),  .ML(FifoDepth)) u_a (.clk_i, .o(oa));
  mid28b #(.MB(TakeThen),  .MI(TakeThen),  .ML(FifoDepth)) u_b (.clk_i, .o(ob));
  mid28b #(.MB(PlainDec),  .MI(PlainDec),  .ML(PlainDec))  u_c (.clk_i, .o(oc));
  mid28b #(.MB(BitPass),   .MI(BitPass),   .ML(BitPass))   u_d (.clk_i, .o(od));

  // F: the package-scope taken-branch ternaries, read through the same chain
  mid28b #(.MB(pq28::QA), .MI(pq28::QB), .ML(pq28::QC)) u_e (.clk_i, .o(oe));
endmodule

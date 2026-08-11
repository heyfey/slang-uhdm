// qa28.sv -- pass-28 grid for THE BASED-LITERAL FOLD DIRECTION at an
// ELABORATED param_assign.  Corpus frontier: prim_fifo_sync.sv:11:40
//   `parameter bit Pass = 1'b1` reached top->rv_core_ibex->tlul_fifo_sync
//   (`parameter int unsigned ReqPass = 1'b1`) -> prim_fifo_sync with
//   `.Pass(ReqPass)`.
//   LHS(golden) constant {ct=3 BIN sz=1 dec=1'b1} / RHS(ours) {ct=9 UINT sz=1
//   dec=1}.
// AXES: declared type (bit / untyped / int unsigned / logic[1:0]) x literal
// base (1'b1 based-binary / 1 plain decimal / 1'd1 based-decimal / 1'h1 hex)
// x scope (package / module param port list / OVERRIDDEN elaborated child).
// The pass-4 four-base x four-view matrix said DEC->INT and OCT->UINT respell
// in the ELABORATED INSTANCE only, HEX and BIN keep -- measured on a PACKAGE
// parameter of type `logic [1:0]`.  `bit` + `1'b1` is a spelling neither that
// matrix nor the ExprEmit ~3251 pkg-param body fold ever measured.

package pk28;
  parameter bit          KB = 1'b1;   // bit   + based-binary
  parameter bit          KD = 1;      // bit   + plain decimal
  parameter              KU = 1'b1;   // untyped + based-binary
  parameter int unsigned KI = 1'b1;   // int unsigned + based-binary
  parameter logic [1:0]  KL = 2'd1;   // the pass-4 row, for continuity
endpackage

// ---------------------------------------------------------------- leaf child
// every parameter here is OVERRIDDEN from mid28, so its elaborated
// param_assign Rhs is the interesting object.
module leaf28 #(
  parameter bit          LB  = 1'b1,  // bit          + based-binary
  parameter bit          LD  = 1,     // bit          + plain decimal
  parameter bit          LH  = 1'h1,  // bit          + hex
  parameter bit          LDD = 1'd1,  // bit          + based-decimal
  parameter              LU  = 1'b1,  // untyped      + based-binary
  parameter int unsigned LI  = 1'b1,  // int unsigned + based-binary
  parameter int unsigned LJ  = 1,     // int unsigned + plain decimal
  parameter logic [1:0]  LL  = 2'b01  // logic [1:0]  + based-binary
) (
  input  logic clk_i,
  output logic o
);
  assign o = clk_i ^ LB ^ LD ^ LH ^ LDD ^ LU[0] ^ LI[0] ^ LJ[0] ^ LL[0];
endmodule

// ------------------------------------------------------- mid, the override hop
module mid28 #(
  parameter int unsigned MPass = 1'b1   // exactly tlul_fifo_sync's ReqPass
) (
  input  logic clk_i,
  output logic o1,
  output logic o2
);
  // A: every leaf parameter OVERRIDDEN from this scope's own parameter
  leaf28 #(.LB(MPass), .LD(MPass), .LH(MPass), .LDD(MPass),
           .LU(MPass), .LI(MPass), .LJ(MPass), .LL(MPass)) u_ovr (
    .clk_i, .o(o1));

  // B: NOTHING overridden -- the same leaf on its own defaults.  This is the
  // control that says whether the respell is override-specific.
  leaf28 u_def (.clk_i, .o(o2));
endmodule

module qa28 (
  input  logic clk_i,
  output logic oa,
  output logic ob,
  output logic oc,
  output logic od,
  output logic oe
);
  localparam bit TPass = 1'b1;

  // C: chain top -> mid -> leaf, override sourced from a bit localparam
  mid28 #(.MPass(TPass)) u_chain (.clk_i, .o1(oa), .o2(ob));

  // D: mid on its own default (so MPass keeps 1'b1 written in mid's own list)
  mid28 u_middef (.clk_i, .o1(oc), .o2(od));

  // E: package parameters read into this module's body
  assign oe = clk_i ^ pk28::KB ^ pk28::KD ^ pk28::KU[0] ^ pk28::KI[0]
              ^ pk28::KL[0];
endmodule

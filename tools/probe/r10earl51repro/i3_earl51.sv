// i3 — how WIDE is the member-LHS rule?  i2 showed golden keeps the OPERATION
// for a member-LHS size cast (`tl_o.size = SZW'(SRAM_DWB)`, the head) AND for a
// member-LHS binary op over a part-select.  This arm asks whether golden EVER
// reduces a member-LHS operation RHS, over six operation shapes that every
// other context folds, each with its plain-net TWIN on the same line pair.
//
// The struct type carries an ENUM member and a NESTED packed struct so the
// output elaborates to a struct_VAR on our side (the Earlgrey `tl_o` shape) —
// that is what makes our emitter mint a FRESH elab cont_assign and fold.
package i3p;
  parameter int unsigned SZW = 2;
  typedef enum logic [2:0] { OP_A = 3'h0, OP_B = 3'h1 } op_e;
  typedef struct packed { logic [6:0] rsvd; logic en; } user_t;
  typedef struct packed {
    logic           valid;
    op_e            opcode;
    logic [3:0]     c1;
    logic [3:0]     c2;
    logic [3:0]     c3;
    logic [3:0]     c4;
    logic [3:0]     c5;
    logic [3:0]     c6;
    logic [3:0]     c7;
    user_t          user;
  } h2d_t;
endpackage

module i3_dut #(
  parameter int DW = 32
) (
  input  logic       req,
  output i3p::h2d_t  tl,
  output logic [3:0] m1,
  output logic [3:0] m2,
  output logic [3:0] m3,
  output logic [3:0] m4,
  output logic [3:0] m5,
  output logic [3:0] m6,
  output logic [3:0] m7
);
  localparam int unsigned LPD = $clog2(DW/8);   // through the module parameter
  localparam int unsigned LP2 = 2;              // plain

  // ---- member-LHS cells ------------------------------------------------
  assign tl.c1 = i3p::SZW'(LPD);          // SIZE CAST of a localparam (THE HEAD)
  assign tl.c2 = LP2 | 4'h1;              // binary op, localparam operand
  assign tl.c3 = 4'h1 | 4'h2;             // binary op, LITERALS only
  assign tl.c4 = (LP2 == 2) ? 4'h1 : 4'h2;// constant-condition ternary
  assign tl.c5 = {2'b01, 2'b10};          // concatenation
  assign tl.c6 = ~4'h1;                   // unary op
  assign tl.c7 = int'(LP2);               // TYPE cast (not a size cast)

  // ---- the plain-net TWINS ---------------------------------------------
  assign m1 = i3p::SZW'(LPD);
  assign m2 = LP2 | 4'h1;
  assign m3 = 4'h1 | 4'h2;
  assign m4 = (LP2 == 2) ? 4'h1 : 4'h2;
  assign m5 = {2'b01, 2'b10};
  assign m6 = ~4'h1;
  assign m7 = int'(LP2);
endmodule

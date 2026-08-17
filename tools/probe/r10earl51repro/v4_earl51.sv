// v4 — POSITIONS THAT ARE NOT A CONT-ASSIGN RHS, plus the cont-assign forms the
// patch could reach through a side door: a DELAYED cont_assign, a cast inside a
// PROCEDURAL member assignment, a cast in a PORT CONNECTION, in a PARAM
// INITIALIZER, in a RANGE BOUND, and a member-Lhs cast inside an INTERFACE.
package v4p;
  parameter int unsigned SZW = 4;
  typedef enum logic [2:0] { OP_A = 3'h0, OP_B = 3'h1 } op_e;
  typedef struct packed { logic [6:0] rsvd; logic en; } user_t;
  typedef struct packed {
    logic       valid;
    op_e        opcode;
    logic [3:0] c1;
    logic [3:0] c2;
    logic [3:0] c3;
    logic [3:0] c4;
    user_t      user;
  } h2d_t;
endpackage

interface v4_if #(parameter int DW = 32) ();
  localparam int unsigned LPD = $clog2(DW/8);
  v4p::h2d_t tl;
  assign tl.c1 = v4p::SZW'(LPD);        // member-Lhs cast inside an INTERFACE
endinterface

module v4_leaf #(
  parameter int W = 4
) (
  input  logic [W-1:0] i,
  output logic [W-1:0] o
);
  assign o = i;
endmodule

module v4_dut #(
  parameter int DW = 32
) (
  input  logic       req,
  output v4p::h2d_t  tl,
  output logic [3:0] n1,
  output logic [3:0] n2
);
  localparam int unsigned LPD = $clog2(DW/8);
  localparam int unsigned LP2 = 2;
  // a cast in a PARAM INITIALIZER
  localparam logic [3:0] LPC = v4p::SZW'(LPD);
  // a cast in a RANGE BOUND
  logic [4'(LP2):0] rngv;
  v4p::h2d_t         pv;

  assign tl.c1 = v4p::SZW'(LPD);        // control: must fire
  assign #1 tl.c2 = v4p::SZW'(LPD);     // DELAYED cont_assign, member Lhs
  assign tl.c3 = LPC;                   // the folded param, no cast
  assign tl.c4 = v4p::SZW'(LP2 + LPD);  // cast of a param expression

  // PROCEDURAL member assignment with a cast — not a cont_assign at all
  always_comb begin
    pv.c1 = v4p::SZW'(LPD);
    pv.c2 = v4p::SZW'(LP2);
  end

  // a cast in a PORT CONNECTION
  v4_leaf #(.W(4)) u_l (.i(v4p::SZW'(LPD)), .o(n1));
  assign n2 = {1'b0, rngv} | pv.c1;
endmodule

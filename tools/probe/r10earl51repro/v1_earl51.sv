// v1 — CAST IN EVERY SYNTACTIC POSITION on a struct-MEMBER Lhs.
// § memberLhsCastNoElabFold51 claims only a cast at the ROOT of the rhs is kept.
// This arm asks what golden does when the cast is nested one level down, is
// parenthesised, is doubled, or is spelled $signed/$unsigned instead of `'`.
package v1p;
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
    logic [3:0] c5;
    logic [3:0] c6;
    logic [3:0] c7;
    logic [3:0] c8;
    logic [3:0] c9;
    user_t      user;
  } h2d_t;
endpackage

module v1_dut #(
  parameter int DW = 32
) (
  input  logic       req,
  output v1p::h2d_t  tl,
  output logic [3:0] n1,
  output logic [3:0] n2,
  output logic [3:0] n3,
  output logic [3:0] n4,
  output logic [3:0] n5,
  output logic [3:0] n6,
  output logic [3:0] n7,
  output logic [3:0] n8,
  output logic [3:0] n9
);
  localparam int unsigned LPD = $clog2(DW/8);
  localparam int unsigned LP2 = 2;

  // ---- member-LHS cells, cast in a different position each ---------------
  assign tl.c1 = (v1p::SZW'(LPD));              // PARENTHESISED cast
  assign tl.c2 = v1p::SZW'(LPD) | 4'h1;         // cast as a binary OPERAND
  assign tl.c3 = (LP2 == 2) ? v1p::SZW'(LPD) : 4'h2;  // cast in a TERNARY branch
  assign tl.c4 = {2'b01, 2'(LP2)};              // cast as a CONCAT operand
  assign tl.c5 = v1p::SZW'(2'(LP2));            // NESTED cast (cast of a cast)
  assign tl.c6 = $signed(LPD);                  // $signed, not a tick-cast
  assign tl.c7 = $unsigned(LPD);                // $unsigned
  assign tl.c8 = signed'(LPD);                  // signed'()  cast form
  assign tl.c9 = 4'(LPD + 1);                   // cast of an EXPRESSION

  // ---- the plain-net TWINS ----------------------------------------------
  assign n1 = (v1p::SZW'(LPD));
  assign n2 = v1p::SZW'(LPD) | 4'h1;
  assign n3 = (LP2 == 2) ? v1p::SZW'(LPD) : 4'h2;
  assign n4 = {2'b01, 2'(LP2)};
  assign n5 = v1p::SZW'(2'(LP2));
  assign n6 = $signed(LPD);
  assign n7 = $unsigned(LPD);
  assign n8 = signed'(LPD);
  assign n9 = 4'(LPD + 1);
endmodule

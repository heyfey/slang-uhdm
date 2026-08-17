// i4 — the BOUNDARY of § memberLhsCastNoElabFold51, on the axes the corpus can
// actually hit and the patch can actually over-fire on:
//   * a CHILD instance view (Earlgrey is 99% child views; the head itself is a
//     standalone top, so the law must be checked on BOTH)
//   * a NESTED member access (tl.user.rsvd), two levels deep
//   * a bit-select / part-select LHS over a packed VAR, with a cast RHS
//   * a member LHS whose cast operand is a LITERAL, and one whose operand is a
//     NET (which cannot fold in any view — the control that proves the arm is
//     reading the fold and not the emitter)
//   * a member LHS on an INTERNAL struct variable (not a port)
package i4p;
  parameter int unsigned SZW = 2;
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

module i4_sub #(
  parameter int DW = 32
) (
  input  logic       req,
  output i4p::h2d_t  tl,
  output logic [3:0] n1,
  output logic [3:0] n2
);
  localparam int unsigned LPD = $clog2(DW/8);
  localparam int unsigned LP2 = 2;

  logic [3:0] pv;            // a packed VAR, for the select-LHS cells
  i4p::h2d_t  loc;           // an INTERNAL struct var (not a port)

  assign tl.c1       = i4p::SZW'(LPD);   // the head's shape, in a CHILD view
  assign tl.c2       = i4p::SZW'(3);     // cast of a LITERAL
  assign tl.c3       = i4p::SZW'(req);   // cast of a NET (never foldable)
  assign tl.user.rsvd= 7'(LP2);          // NESTED member, two levels
  assign loc.c1      = i4p::SZW'(LPD);   // internal struct var
  assign pv[3:0]     = i4p::SZW'(LPD);   // PART-select LHS over a packed var
  assign pv[0]       = 1'(LP2);          // BIT-select LHS over a packed var

  assign n1 = i4p::SZW'(LPD);            // the plain-net twin
  assign n2 = i4p::SZW'(3);
endmodule

module i4_earl51 (
  input  logic       req,
  output i4p::h2d_t  a_tl,
  output i4p::h2d_t  b_tl,
  output logic [3:0] a_n1,
  output logic [3:0] a_n2,
  output logic [3:0] b_n1,
  output logic [3:0] b_n2
);
  i4_sub #(.DW(32)) u_a (.req(req), .tl(a_tl), .n1(a_n1), .n2(a_n2));
  i4_sub #(.DW(64)) u_b (.req(req), .tl(b_tl), .n1(b_n1), .n2(b_n2));
endmodule

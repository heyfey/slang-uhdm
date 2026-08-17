// v2 — the LHS axis.  § memberLhsCastNoElabFold51 keys on the Lhs being a
// MemberAccess chain.  What does golden do when the member access is WRAPPED in
// a select, when the member is reached THROUGH an array element, when the Lhs is
// a CONCAT containing a member, and when the struct lives in a GENERATE block or
// is a UNION?
package v2p;
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
    user_t      user;
  } h2d_t;
  typedef union packed {
    logic [7:0] w;
    struct packed { logic [3:0] hi; logic [3:0] lo; } f;
  } u_t;
endpackage

module v2_dut #(
  parameter int DW = 32
) (
  input  logic          req,
  output v2p::h2d_t     tl,
  output v2p::h2d_t     arr [0:1],   // UNPACKED array of the struct
  output v2p::u_t       un,
  output logic [3:0]    n1
);
  localparam int unsigned LPD = $clog2(DW/8);
  localparam int unsigned LP2 = 2;

  assign tl.c1[3:0]   = v2p::SZW'(LPD);   // PART-select OF a member
  assign tl.c2[0]     = 1'(LP2);          // BIT-select OF a member
  assign {tl.c3, tl.c4} = 8'(LPD);        // CONCAT Lhs containing members
  assign arr[0].c1    = v2p::SZW'(LPD);   // member THROUGH an array element
  assign un.f.hi      = v2p::SZW'(LPD);   // UNION member, two levels
  assign tl.user.rsvd = 7'(LP2);          // nested member (control: must fire)
  assign tl.c5        = v2p::SZW'(LPD);   // plain member (control: must fire)
  assign n1           = v2p::SZW'(LPD);   // plain net twin (control: folds)

  if (1) begin : g
    v2p::h2d_t gl;
    assign gl.c1 = v2p::SZW'(LPD);        // member LHS inside a GENERATE block
  end
endmodule

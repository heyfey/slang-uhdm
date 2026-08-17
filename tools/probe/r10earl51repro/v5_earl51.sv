// v5 — the last over-fire hunt: shapes where golden might FOLD a member-Lhs
// cast (which would make § memberLhsCastNoElabFold51 a REGRESSION), plus the
// neighbouring rhs forms that also carry a typespec in Surelog.
package v5p;
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
    user_t      user;
  } h2d_t;
endpackage

module v5_dut #(
  parameter int DW = 32
) (
  input  logic       req,
  output v5p::h2d_t  tl,
  inout  v5p::h2d_t  io,
  output logic [3:0] n1
);
  localparam int unsigned LPD = $clog2(DW/8);
  localparam int unsigned LP2 = 2;
  localparam real       LPR = 2.0;

  assign tl.opcode = v5p::op_e'(1);        // cast into an ENUM-typed member
  assign tl.user   = v5p::user_t'{rsvd:7'h1, en:1'b0}; // typed assignment pattern
  assign tl.c1     = v5p::SZW'($clog2(8)); // cast of a SYS FUNC CALL
  assign tl.c2     = int'(LPR);            // cast of a REAL localparam
  assign tl.c3     = v5p::SZW'(LP2 ? 1 : 2); // cast of a ternary
  assign tl.c4     = v5p::SZW'(LPD) ;      // control: must fire
  assign tl.c5     = 4'(4'h3);             // cast of a SAME-WIDTH literal
  assign tl.c6     = v5p::SZW'(req);       // cast of a NET (never foldable)
  assign tl.c7     = v5p::SZW'(1'b1);      // cast of a 1-bit literal
  assign io.c1     = v5p::SZW'(LPD);       // member of an INOUT struct port
  assign n1        = v5p::SZW'($clog2(8));
endmodule

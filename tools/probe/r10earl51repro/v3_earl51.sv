// v3 — the CAST-TARGET axis.  Where does the cast's width/type come from, and
// does golden's "keep the operation" survive every spelling?
//   * width from a package parameter / a module parameter / a localparam /
//     a plain literal / a computed expression
//   * a TYPE cast to a typedef, to an enum, to a packed struct, to `int`,
//     to `logic signed [..]`, and a `type(x)'()` cast
package v3p;
  parameter int unsigned SZW = 4;
  typedef enum logic [3:0] { OP_A = 4'h0, OP_B = 4'h1 } op_e;
  typedef logic [3:0] nib_t;
  typedef struct packed { logic [1:0] a; logic [1:0] b; } pair_t;
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
    logic [3:0] ca;
    user_t      user;
  } h2d_t;
endpackage

module v3_dut #(
  parameter int DW  = 32,
  parameter int MW  = 4
) (
  input  logic       req,
  output v3p::h2d_t  tl,
  output logic [3:0] n1,
  output logic [3:0] n2
);
  localparam int unsigned LPD = $clog2(DW/8);
  localparam int unsigned LP2 = 2;
  localparam int unsigned LPW = 4;

  assign tl.c1 = v3p::SZW'(LPD);       // width from a PACKAGE parameter
  assign tl.c2 = MW'(LPD);             // width from a MODULE parameter
  assign tl.c3 = LPW'(LPD);            // width from a LOCALPARAM
  assign tl.c4 = 4'(LPD);              // width from a LITERAL
  assign tl.c5 = (LPW+0)'(LPD);        // width from a COMPUTED expression
  assign tl.c6 = v3p::nib_t'(LPD);     // TYPE cast to a typedef
  assign tl.c7 = v3p::op_e'(LP2);      // TYPE cast to an ENUM
  assign tl.c8 = v3p::pair_t'(LPD);    // TYPE cast to a packed STRUCT
  assign tl.c9 = int'(LP2);            // TYPE cast to int
  assign tl.ca = logic'(LP2);          // TYPE cast to `logic`

  assign n1 = v3p::nib_t'(LPD);        // net twins
  assign n2 = v3p::op_e'(LP2);
endmodule

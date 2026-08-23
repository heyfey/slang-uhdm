// r10earl72 g1 — POSITION grid for § caOpFoldTs's ELAB half.
// ONE wildcard-imported package `int` parameter (the flash_phy_pkg::NumBuf
// shape) read in EVERY operand position a module-body cont_assign offers, in
// a module instantiated once at module scope.  Every row is measured in the
// DEF listing AND in the ELABORATED instance body, default and --elabuhdm.
// The question the grid answers: WHEN does golden stamp the folded read with
// the package parameter's own declaration typespec?
package g1p;
  parameter int NB = 4;
endpackage

module g1sub #(parameter int W = 1) (input logic [W-1:0] pi);
endmodule

module g1m import g1p::*; (
  input  logic        req_i,
  input  logic [31:0] bus_i,
  output logic [15:0] o_i
);
  logic [15:0] buf_alloc;
  logic [15:0] wide;

  // P1 repeat count, TWO operations deep (the Earlgrey head shape)
  logic [15:0] p1; assign p1 = {NB{req_i}} & buf_alloc;
  // P2 repeat count, ONE operation deep
  logic [3:0]  p2; assign p2 = {NB{req_i}};
  // P3 concat MEMBER
  logic [35:0] p3; assign p3 = {NB, bus_i};
  // P4 operand of a binary operation
  logic [31:0] p4; assign p4 = NB + 32'h1;
  // P5 bit-select INDEX
  logic        p5; assign p5 = bus_i[NB];
  // P6 part-select bound (left)
  logic [3:0]  p6; assign p6 = bus_i[NB:1];
  // P7 part-select bound inside arithmetic
  logic [3:0]  p7; assign p7 = bus_i[NB-1:0];
  // P8 the WHOLE Rhs
  logic [31:0] p8; assign p8 = NB;
  // P9 indexed part-select width
  logic [3:0]  p9; assign p9 = bus_i[1 +: NB];
  // P10 ternary arm
  logic [31:0] p10; assign p10 = req_i ? NB : 32'h7;
  // P11 nested three operations deep
  logic [15:0] p11; assign p11 = ({NB{req_i}} & buf_alloc) | wide;
  // P12 a system-function argument (negative control per § caOpFoldTs)
  logic [31:0] p12; assign p12 = $clog2(NB);
  // P13 net-decl-assign (compiled in the netlist pass, contAssignView 0)
  wire  [31:0] p13 = NB + 32'h1;
  // P14 a PORT-CONNECTION replication count (the rstmgr shape)
  g1sub #(.W(NB)) u_sub (.pi({NB{1'b1}}));

  assign o_i = p1 | p2 | wide;
endmodule

module g1top;
  logic r; logic [31:0] b; logic [15:0] o;
  g1m u0(.req_i(r), .bus_i(b), .o_i(o));
endmodule

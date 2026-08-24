// r10v79 adversarial arm 7 — THE ONLY WAY PRISTINE CAN ALREADY BE RIGHT.
// For an EXPRESSION bound `dimPar26` is null, so wide26/ovrNarrow26/tsStamp26
// are all false and pristine's size is w0 = the BOUND EXPRESSION'S OWN bound
// type width.  w0 is 32 for every ordinary `int`-flavoured expression — but a
// 64-BIT OPERAND makes w0 = 64, i.e. pristine already equals golden's size and
// the ONLY field left for the patch to move is VpiConstType.
module sink7 #(
  parameter int unsigned N = 4
) (input logic clk);
  localparam longint LB = N * 2;   // 64-bit type, INT-flavoured initializer
  localparam longint LC = N + 1;   // 64-bit type, UINT-flavoured initializer
  localparam longint LD = 6;       // 64-bit type, literal initializer

  logic [7:0] x_bl  [N + 64'd1];    // based DECIMAL, 64 wide
  logic [7:0] x_bs  [N + 64'sd1];   // based SIGNED decimal, 64 wide
  logic [7:0] x_bh  [N + 64'h1];    // based HEX, 64 wide
  logic [7:0] x_lb  [LB + 1];       // 64-bit name, INT-flavoured
  logic [7:0] x_lc  [LC + 1];       // 64-bit name, UINT-flavoured
  logic [7:0] x_ld  [LD + 1];       // 64-bit name, literal-flavoured
  logic [7:0] x_or  [N | 64'd8];    // bitwise-or with a 64-wide operand
  logic [7:0] x_mul [LB * 2];       // multiply with a 64-bit name
endmodule

module top7;
  logic clk;
  sink7 #(.N(5)) u_a (.clk(clk));
  sink7 #(.N(7)) u_b (.clk(clk));
endmodule

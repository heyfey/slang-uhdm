package ip;
  parameter int unsigned A32  = 32;
  parameter int unsigned SUB  = A32 - 8 - 3 + 1;   // INT chain
  parameter int unsigned ADDU = A32 + 8;           // UINT
  parameter int unsigned MUL  = A32 * 2;           // INT
  parameter int unsigned CLG  = $clog2(A32);       // UINT
  parameter int unsigned LIT  = 22;                // UINT
  parameter int unsigned HOP  = SUB;               // a hop of an INT
  parameter logic [7:0]  LVEC = 8'hA5;
  parameter int unsigned CAT  = {8'd1, 8'd2};
  parameter int unsigned NEG  = 0 - 5;
  parameter int unsigned CMPV = (A32 > 8);
endpackage
module m import ip::*; #(
  parameter int unsigned P_SUB   = SUB,
  parameter int unsigned P_QSUB  = ip::SUB,
  parameter int unsigned P_HOP   = HOP,
  parameter int unsigned P_ADDU  = ADDU,
  parameter int unsigned P_MUL   = MUL,
  parameter int unsigned P_CLG   = CLG,
  parameter int unsigned P_LIT   = LIT,
  parameter int unsigned P_LVEC  = LVEC,
  parameter int unsigned P_CAT   = CAT,
  parameter int unsigned P_NEG   = NEG,
  parameter int unsigned P_CMPV  = CMPV,
  parameter int          P_ISUB  = SUB,
  parameter              P_XSUB  = SUB,
  parameter bit [7:0]    P_BSUB  = SUB,
  parameter logic [15:0] P_LSUB  = SUB,
  parameter int unsigned P_EXPR  = SUB + 1,
  parameter int unsigned P_EXPR2 = SUB * 2,
  parameter int unsigned P_OV    = SUB
) ();
  localparam int unsigned L_SUB  = SUB;
  localparam int unsigned L_LOC  = P_SUB;
  localparam int unsigned L_LOCL = L_SUB;
  localparam int unsigned L_ADDU = ADDU;
  localparam int unsigned L_EXPR = SUB + 1;
endmodule
module top;
  m #() u0();
  m #(.P_OV(7)) u1();
endmodule

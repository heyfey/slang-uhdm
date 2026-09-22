// r11v94 BREAK arm x2 — LAWS B/C on the minus shapes the implementer's
// q4/q5/q6 do NOT hold: a subtraction of BASED literals, a POSITIVE result
// wider than a NARROW declared type, a 64-bit and a 128-bit negative (does
// the int64 reduce still answer?), the two int64 extremes, a minus over a
// based literal, a concatenation minus one, an ADD whose operand is negative,
// and the MULT/DIV top-level controls the implementer records as R0.
package x2p;
  localparam logic [7:0]   BH2   = 8'hF0 - 8'h01;
  localparam logic [3:0]   BN    = 20 - 1;
  localparam logic [63:0]  B64   = -1;
  localparam logic [127:0] B128  = -3;
  localparam int           BMIN  = -2147483647 - 1;
  localparam longint       BLMIN = -9223372036854775807;
  localparam int           BSUBN = 3 - 5;
  localparam logic [7:0]   BNN   = -(8'd3);
  localparam int           BMULM = 2 * (-3);
  localparam int           BDIVM = (-6) / 2;
  localparam int           BADDN = -3 + 0;
  localparam logic [7:0]   BCAT  = {4'd1, 4'd2} - 1;
  localparam int           BSH   = 8 >> 1;
  localparam int           BMOD  = 7 % 4;
endpackage
module x2_minusedge94v (output logic [63:0] o);
  wire signed [31:0]  wBH2   = x2p::BH2;
  wire signed [31:0]  wBN    = x2p::BN;
  wire signed [63:0]  wB64   = x2p::B64;
  wire signed [63:0]  wB128  = x2p::B128;
  wire signed [31:0]  wBMIN  = x2p::BMIN;
  wire signed [63:0]  wBLMIN = x2p::BLMIN;
  wire signed [31:0]  wBSUBN = x2p::BSUBN;
  wire signed [31:0]  wBNN   = x2p::BNN;
  wire signed [31:0]  wBMULM = x2p::BMULM;
  wire signed [31:0]  wBDIVM = x2p::BDIVM;
  wire signed [31:0]  wBADDN = x2p::BADDN;
  wire signed [31:0]  wBCAT  = x2p::BCAT;
  wire signed [31:0]  wBSH   = x2p::BSH;
  wire signed [31:0]  wBMOD  = x2p::BMOD;
  assign o = {wBH2, wBN} ^ wB64 ^ wB128 ^ {wBMIN, wBSUBN} ^ wBLMIN ^
             {wBNN, wBMULM} ^ {wBDIVM, wBADDN} ^ {wBCAT, wBSH} ^
             {wBMOD, wBH2};
endmodule

// r11v97 VERIFIER arm k4 — LAW A on the operand positions z1 does not carry:
// BOTH operands unbased, an unbased under a `**` on either side, a `>>`, a
// unary minus wrapping an operation, `'1` divided/modded by itself, a BYTE
// declaration, an unbased child under an INT-minting parent (LAW B x LAW A),
// and an unbased under a comparison on both sides (LAW C x LAW A).
package k4p;
  localparam int          A2   = '1 - '1;
  localparam int          A3   = ('1 - 0) * 1;
  localparam longint      A4   = '1 * 2;
  localparam logic [63:0] A5   = '1 - 0;
  localparam int          A6   = '1 ** 1;
  localparam int          A7   = 2 ** '1;
  localparam int          A8   = '1 >> 1;
  localparam int          A9   = -('1 - 0);
  localparam int          A10  = 1 - '1;
  localparam int          A12  = '0 - 1;
  localparam int          A13  = '1 / '1;
  localparam int          A14  = '1 % '1;
  localparam byte         A15  = '1 - 0;
  localparam int          A16  = ('1 - 0) + 1;
  localparam int          A17  = ('1 < 2);
  localparam int          A18  = (2 < '1);
  localparam int          A19  = ('1 == '1);
  localparam int          A20  = ('0 < '1);
  // ===== THE LIVE CONTROLS
  localparam int          CB1S = 1'b1 - 0;
  localparam int          CSUB = 8 - 1;
  localparam int          CADD = 1 + 2;
endpackage
module k4_unbop94v (output logic [63:0] o);
  wire signed [31:0] wA2  = k4p::A2;
  wire signed [31:0] wA3  = k4p::A3;
  wire signed [63:0] wA4  = k4p::A4;
  wire        [63:0] wA5  = k4p::A5;
  wire signed [31:0] wA6  = k4p::A6;
  wire signed [31:0] wA7  = k4p::A7;
  wire signed [31:0] wA8  = k4p::A8;
  wire signed [31:0] wA9  = k4p::A9;
  wire signed [31:0] wA10 = k4p::A10;
  wire signed [31:0] wA12 = k4p::A12;
  wire signed [31:0] wA13 = k4p::A13;
  wire signed [31:0] wA14 = k4p::A14;
  wire signed [7:0]  wA15 = k4p::A15;
  wire signed [31:0] wA16 = k4p::A16;
  wire signed [31:0] wA17 = k4p::A17;
  wire signed [31:0] wA18 = k4p::A18;
  wire signed [31:0] wA19 = k4p::A19;
  wire signed [31:0] wA20 = k4p::A20;
  wire signed [31:0] wCB1S = k4p::CB1S;
  wire signed [31:0] wCSUB = k4p::CSUB;
  wire signed [31:0] wCADD = k4p::CADD;
  assign o = {wA2, wA3} ^ wA4 ^ wA5 ^ {wA6, wA7} ^ {wA8, wA9} ^
             {wA10, wA12} ^ {wA13, wA14} ^ {24'd0, wA15, wA16} ^
             {wA17, wA18} ^ {wA19, wA20} ^ {wCB1S, wCSUB} ^ {wCADD, 32'd0};
endmodule

// r11u96 arm y2 — LAW B, the UNSIZED DECIMAL leaf past 32 bits.  slang types an
// unsized decimal literal `int` and TRUNCATES its digits to 32 bits; Surelog's
// `get_value` reads the written `DEC:` string whole.  The grid crosses the
// magnitude (31 / 32 / 33 / 63 / 64 bits and past int64) with the reduce arm
// that carries it (unary minus, subtract, multiply, add, none at all) and with
// the reading net's signedness.
package y2p;
  localparam longint BLMIN = -9223372036854775807;
  localparam longint BLMAX = 9223372036854775807 - 0;
  localparam longint BLBARE = 9223372036854775807;
  localparam longint B33   = 8589934592 - 0;
  localparam longint B33M  = -8589934592;
  localparam longint B32   = 4294967296 - 0;
  localparam longint B31   = 2147483648 - 0;
  localparam longint B31M  = -2147483648;
  localparam longint B30   = 1073741824 - 0;
  localparam longint BMULU = 4294967296 * 2;
  localparam longint BADDU = 4294967296 + 1;
  localparam longint BDIVU = 8589934592 / 2;
  localparam longint BSMALL = 6 - 1;
  localparam longint BHEXW = 64'h1_0000_0000 - 0;
endpackage
module y2_unsized96 (output logic [63:0] o);
  wire signed [63:0] wBLMIN  = y2p::BLMIN;
  wire signed [63:0] wBLMAX  = y2p::BLMAX;
  wire signed [63:0] wBLBARE = y2p::BLBARE;
  wire signed [63:0] wB33    = y2p::B33;
  wire signed [63:0] wB33M   = y2p::B33M;
  wire signed [63:0] wB32    = y2p::B32;
  wire signed [63:0] wB31    = y2p::B31;
  wire signed [63:0] wB31M   = y2p::B31M;
  wire signed [63:0] wB30    = y2p::B30;
  wire signed [63:0] wBMULU  = y2p::BMULU;
  wire signed [63:0] wBADDU  = y2p::BADDU;
  wire signed [63:0] wBDIVU  = y2p::BDIVU;
  wire signed [63:0] wBSMALL = y2p::BSMALL;
  wire signed [63:0] wBHEXW  = y2p::BHEXW;
  wire        [63:0] wUB33   = y2p::B33;
  wire        [63:0] wUBLMIN = y2p::BLMIN;
  wire signed [31:0] wNB33   = y2p::B33;
  assign o = wBLMIN ^ wBLMAX ^ wBLBARE ^ wB33 ^ wB33M ^ wB32 ^ wB31 ^
             wB31M ^ wB30 ^ wBMULU ^ wBADDU ^ wBDIVU ^ wBSMALL ^ wBHEXW ^
             wUB33 ^ wUBLMIN ^ {wNB33, wNB33};
endmodule

// r11u100 arm p2 — LAW B, THE DIGITS ROAD WITHOUT THE CONST-TYPE ROAD.
// `vpiAddOp` (:3284), `vpiBitAndOp` (:3350), `vpiBitOrOp` (:3329) and the two
// shift arms (:3149 / :3236) all read the WRITTEN DIGITS through
// `get_value`/`get_uvalue` and mint `UINT:` at 64 bits; `CompileHelper::
// adjustSize`'s `vpiUIntConst` branch (:4108-4118) then MASKS that value to
// the declaration's width.  slang truncates an unsized decimal at 2^31, so the
// two readings part at every magnitude past that.  Crossed: operator x
// magnitude (2^31 / 2^32 / 2^63) x declared width.
package p2p;
  localparam longint BADDU  = 4294967296 + 1;
  localparam longint BADDR  = 1 + 4294967296;
  localparam longint BADD31 = 2147483648 + 1;
  localparam longint BADD63 = 4611686018427387904 + 1;
  localparam longint BADDS  = 9223372036854775807 + 1;
  localparam longint BANDU  = 4294967296 & 4294967296;
  localparam longint BANDM  = 4294967296 & 12884901888;
  localparam longint BAND31 = 2147483648 & 2147483648;
  localparam longint BORU   = 4294967296 | 1;
  localparam longint BOR31  = 2147483648 | 1;
  localparam longint BSHL   = 2147483648 << 1;
  localparam longint BSHL2  = 1 << 33;
  localparam longint BSHR   = 4294967296 >> 1;
  localparam longint BSHRA  = 4294967296 >>> 1;
  localparam longint BSHLA  = 2147483648 <<< 1;
  // the DECLARED WIDTH is the mask — the same digits at 32 bits
  localparam int     IADDU  = 4294967296 + 1;
  localparam int     IADD31 = 2147483648 + 1;
  localparam int     IANDU  = 4294967296 & 4294967296;
  localparam int     ISHL   = 2147483648 << 1;
  localparam byte    YADD   = 200 + 100;
  localparam logic [7:0] U8ADD = 200 + 100;
  localparam logic [15:0] U16SHL = 2147483648 << 1;
  // the '1 face (r11u97's R2) rides on the same arms
  localparam int     U1ADD  = '1 + 0;
  localparam int     U1AND  = '1 & 3;
  localparam int     U1OR   = '1 | 0;
  localparam longint U1ADDL = '1 + 0;
  // a BASED leaf on the same arms (r11u76's digits)
  localparam longint HADD   = 64'h1_0000_0000 + 1;
  localparam longint HAND   = 64'h1_0000_0000 & 64'h1_0000_0000;
  // the LIVE CONTROLS — every one EQUAL on both binaries
  localparam int     CADD   = 1 + 2;
  localparam int     CAND   = 12 & 10;
  localparam int     COR    = 12 | 3;
  localparam int     CSHL   = 1 << 3;
  localparam int     CSHR   = 32 >> 2;
  localparam longint CXOR   = 4294967296 ^ 1;
  localparam longint CLAND  = 4294967296 && 1;
  localparam longint CLOR   = 4294967296 || 0;
  localparam longint CTERN  = 1 ? 4294967296 : 0;
  localparam longint CMULI  = 4294967296 * 2;
  localparam longint CSUBI  = 4294967296 - 0;
  localparam longint CADDI  = 8'd10 + 1;
  localparam longint CNEST  = (4294967296 & 4294967296) + 1;
  localparam longint CNAME  = BADDU + 1;
endpackage
module p2_uintdig100 (output logic [63:0] o);
  wire signed [63:0] wBADDU  = p2p::BADDU;
  wire signed [63:0] wBADDR  = p2p::BADDR;
  wire signed [63:0] wBADD31 = p2p::BADD31;
  wire signed [63:0] wBADD63 = p2p::BADD63;
  wire signed [63:0] wBADDS  = p2p::BADDS;
  wire signed [63:0] wBANDU  = p2p::BANDU;
  wire signed [63:0] wBANDM  = p2p::BANDM;
  wire signed [63:0] wBAND31 = p2p::BAND31;
  wire signed [63:0] wBORU   = p2p::BORU;
  wire signed [63:0] wBOR31  = p2p::BOR31;
  wire signed [63:0] wBSHL   = p2p::BSHL;
  wire signed [63:0] wBSHL2  = p2p::BSHL2;
  wire signed [63:0] wBSHR   = p2p::BSHR;
  wire signed [63:0] wBSHRA  = p2p::BSHRA;
  wire signed [63:0] wBSHLA  = p2p::BSHLA;
  wire signed [63:0] wIADDU  = p2p::IADDU;
  wire signed [63:0] wIADD31 = p2p::IADD31;
  wire signed [63:0] wIANDU  = p2p::IANDU;
  wire signed [63:0] wISHL   = p2p::ISHL;
  wire signed [63:0] wYADD   = p2p::YADD;
  wire signed [63:0] wU8ADD  = p2p::U8ADD;
  wire signed [63:0] wU16SHL = p2p::U16SHL;
  wire signed [63:0] wU1ADD  = p2p::U1ADD;
  wire signed [63:0] wU1AND  = p2p::U1AND;
  wire signed [63:0] wU1OR   = p2p::U1OR;
  wire signed [63:0] wU1ADDL = p2p::U1ADDL;
  wire signed [63:0] wHADD   = p2p::HADD;
  wire signed [63:0] wHAND   = p2p::HAND;
  wire signed [63:0] wCADD   = p2p::CADD;
  wire signed [63:0] wCAND   = p2p::CAND;
  wire signed [63:0] wCOR    = p2p::COR;
  wire signed [63:0] wCSHL   = p2p::CSHL;
  wire signed [63:0] wCSHR   = p2p::CSHR;
  wire signed [63:0] wCXOR   = p2p::CXOR;
  wire signed [63:0] wCLAND  = p2p::CLAND;
  wire signed [63:0] wCLOR   = p2p::CLOR;
  wire signed [63:0] wCTERN  = p2p::CTERN;
  wire signed [63:0] wCMULI  = p2p::CMULI;
  wire signed [63:0] wCSUBI  = p2p::CSUBI;
  wire signed [63:0] wCADDI  = p2p::CADDI;
  wire signed [63:0] wCNEST  = p2p::CNEST;
  wire signed [63:0] wCNAME  = p2p::CNAME;
  wire        [63:0] wUBADDU = p2p::BADDU;
  wire signed [31:0] wNBADDU = p2p::BADDU;
  assign o = wBADDU ^ wBADDR ^ wBADD31 ^ wBADD63 ^ wBADDS ^ wBANDU ^ wBANDM ^
             wBAND31 ^ wBORU ^ wBOR31 ^ wBSHL ^ wBSHL2 ^ wBSHR ^ wBSHRA ^
             wBSHLA ^ wIADDU ^ wIADD31 ^ wIANDU ^ wISHL ^ wYADD ^ wU8ADD ^
             wU16SHL ^ wU1ADD ^ wU1AND ^ wU1OR ^ wU1ADDL ^ wHADD ^ wHAND ^
             wCADD ^ wCAND ^ wCOR ^ wCSHL ^ wCSHR ^ wCXOR ^ wCLAND ^ wCLOR ^
             wCTERN ^ wCMULI ^ wCSUBI ^ wCADDI ^ wCNEST ^ wCNAME ^ wUBADDU ^
             {wNBADDU, wNBADDU};
endmodule

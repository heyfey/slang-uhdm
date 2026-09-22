// r11v97 VERIFIER arm k1 — LAW C's DECLARED-TYPE face and its OPERAND kinds.
// The implementer measured `int`, a typedef of int, integer, int unsigned,
// signed 32-bit logic/bit, longint, byte, bit, logic and the implicit type.
// This arm adds the types and operand shapes it did NOT carry: a typedef of a
// NON-int type, shortint, byte unsigned, time, a PACKED ARRAY, a REAL
// declaration, real operands, STRING operands, an ENUM operand, a system
// call, a `**` and a `<<` child (including the `'1 << 1` one whose golden the
// producer refuses for VpiSize(-1)), and a chain over a comparison.
package k1p;
  typedef int                 td_int_t;
  typedef logic [7:0]         td_l8_t;
  typedef bit signed [31:0]   td_bs32_t;
  typedef enum int { KA = 1, KB = 2 } k1e_t;
  localparam int              CI    = (3 < 4);
  localparam td_int_t         CTD   = (3 < 4);
  localparam td_l8_t          CTL8  = (3 < 4);
  localparam td_bs32_t        CTBS  = (3 < 4);
  localparam shortint         CSH   = (3 < 4);
  localparam byte unsigned    CBYU  = (3 < 4);
  localparam time             CTM   = (3 < 4);
  localparam integer          CIG   = (3 < 4);
  localparam logic [2:0][3:0] CPA   = (3 < 4);
  localparam real             CRL   = (3 < 4);
  localparam int              CRLOP = (3.0 < 4.0);
  localparam int              CSTRC = ("ab" < "ac");
  localparam int              CSYS  = ($clog2(16) < 5);
  localparam int              CPOWC = ((2 ** 3) < 9);
  localparam int              CSHLC = ((1 << 3) < 9);
  localparam int              CSHLU = (('1 << 1) < 3);
  localparam int              CBASE = (8'd10 < 8'h0b);
  localparam int              CNEGN = (-5 < -4);
  localparam int              CMIN  = (-2147483647 < 0);
  localparam int              CEQ0  = (0 == 0);
  localparam int              CCHNC = (CI < 0);
  localparam int              CDIVC = ((6 / 2) < 4);
  localparam int              CMODC = ((7 % 4) < 4);
  localparam int              CUNM  = ((-3) < 0);
  localparam int              CENMC = (KA < KB);
  // ===== THE LIVE CONTROLS — not on reduceCompOp's road at all.
  localparam int              CAND  = (1 && 1);
  localparam int              CNOT  = (!0);
  localparam int              CPLAIN= 2 * 3;
  localparam int              CADD  = 1 + 2;
endpackage
module k1_ctype94v (output logic [63:0] o);
  wire signed [31:0] wCI    = k1p::CI;
  wire signed [31:0] wCTD   = k1p::CTD;
  wire        [7:0]  wCTL8  = k1p::CTL8;
  wire signed [31:0] wCTBS  = k1p::CTBS;
  wire signed [31:0] wCSH   = k1p::CSH;
  wire        [7:0]  wCBYU  = k1p::CBYU;
  wire        [63:0] wCTM   = k1p::CTM;
  wire signed [31:0] wCIG   = k1p::CIG;
  wire        [11:0] wCPA   = k1p::CPA;
  wire signed [31:0] wCRLOP = k1p::CRLOP;
  wire signed [31:0] wCSTRC = k1p::CSTRC;
  wire signed [31:0] wCSYS  = k1p::CSYS;
  wire signed [31:0] wCPOWC = k1p::CPOWC;
  wire signed [31:0] wCSHLC = k1p::CSHLC;
  wire signed [31:0] wCSHLU = k1p::CSHLU;
  wire signed [31:0] wCBASE = k1p::CBASE;
  wire signed [31:0] wCNEGN = k1p::CNEGN;
  wire signed [31:0] wCMIN  = k1p::CMIN;
  wire signed [31:0] wCEQ0  = k1p::CEQ0;
  wire signed [31:0] wCCHNC = k1p::CCHNC;
  wire signed [31:0] wCDIVC = k1p::CDIVC;
  wire signed [31:0] wCMODC = k1p::CMODC;
  wire signed [31:0] wCUNM  = k1p::CUNM;
  wire signed [31:0] wCENMC = k1p::CENMC;
  wire signed [31:0] wCAND  = k1p::CAND;
  wire signed [31:0] wCNOT  = k1p::CNOT;
  wire signed [31:0] wCPLN  = k1p::CPLAIN;
  wire signed [31:0] wCADD  = k1p::CADD;
  assign o = {wCI, wCTD} ^ {20'd0, wCTL8, 24'd0, wCTBS[7:0]} ^
             {wCSH, wCIG} ^ {24'd0, wCBYU, 20'd0, wCPA} ^ wCTM ^
             {wCRLOP, wCSTRC} ^ {wCSYS, wCPOWC} ^ {wCSHLC, wCSHLU} ^
             {wCBASE, wCNEGN} ^ {wCMIN, wCEQ0} ^ {wCCHNC, wCDIVC} ^
             {wCMODC, wCUNM} ^ {wCENMC, wCAND} ^ {wCNOT, wCPLN} ^
             {wCADD, 32'd0};
endmodule

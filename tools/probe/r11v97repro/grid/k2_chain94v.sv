// r11v97 VERIFIER arm k2 — § chainStoreChecksTheInitializer97 IS A WIDENING OF
// A SHARED GUARD.  The implementer measured the chain over the three DIGIT
// arms.  This arm crosses the chain with every OTHER road on which our reduce
// and slang's store are known to disagree: the `**` cast artefact
// (§ patPowCastArtefact73), the shifts (§ redShiftIsUnsignedSixtyFour78), a
// MASKED narrow store, a wide multiply past the declared width, a based HEX
// leaf, an enum member, and an OVERRIDDEN port parameter as the control that
// must still decline.
package k2p;
  localparam int         PW    = 2 ** 40;          // store 0, reduce 2^40
  localparam int         PWC   = PW - 0;
  localparam longint     PW63  = 2 ** 63;          // the INT64_MIN artefact
  localparam longint     PW63C = PW63 - 0;
  localparam longint     SHL   = 2147483648 << 1;  // RV96-5's road
  localparam longint     SHLC  = SHL - 0;
  localparam int         WBH   = 8'h0c - 0;        // r11u76's based leaf
  localparam int         WBHC  = WBH - 0;
  localparam logic [7:0] NU    = 300 - 0;          // store MASKED to 44
  localparam int         NUC   = NU - 0;
  localparam int         NEG   = 0 - 3;
  localparam int         NEGC  = NEG - 0;
  localparam int         BIGM  = 2147483647 * 2;   // store wraps, reduce wide
  localparam int         BIGMC = BIGM - 0;
  localparam longint     BIGD  = 4294967296 * 2;
  localparam longint     BIGDC = BIGD - 0;
  typedef enum int { EM = 2 * 3 } k2e_t;
  localparam int         ENC   = EM - 0;           // a chain over an ENUM
  // ===== THE LIVE CONTROLS
  localparam int         PLAIN = 2 * 3;
  localparam int         PCHN  = PLAIN * 2;
  localparam int         ADDC  = 1 + 2;
  localparam int         ACHN  = ADDC + 1;
endpackage
module k2_sub #(parameter int SP = 2 ** 40) (output logic [31:0] q);
  localparam int SPC = SP - 0;
  assign q = SPC;
endmodule
module k2_chain94v (output logic [63:0] o);
  wire signed [31:0] wPW    = k2p::PW;
  wire signed [31:0] wPWC   = k2p::PWC;
  wire signed [63:0] wPW63  = k2p::PW63;
  wire signed [63:0] wPW63C = k2p::PW63C;
  wire signed [63:0] wSHL   = k2p::SHL;
  wire signed [63:0] wSHLC  = k2p::SHLC;
  wire signed [31:0] wWBH   = k2p::WBH;
  wire signed [31:0] wWBHC  = k2p::WBHC;
  wire        [7:0]  wNU    = k2p::NU;
  wire signed [31:0] wNUC   = k2p::NUC;
  wire signed [31:0] wNEG   = k2p::NEG;
  wire signed [31:0] wNEGC  = k2p::NEGC;
  wire signed [31:0] wBIGM  = k2p::BIGM;
  wire signed [31:0] wBIGMC = k2p::BIGMC;
  wire signed [63:0] wBIGD  = k2p::BIGD;
  wire signed [63:0] wBIGDC = k2p::BIGDC;
  wire signed [31:0] wENC   = k2p::ENC;
  wire signed [31:0] wPLAIN = k2p::PLAIN;
  wire signed [31:0] wPCHN  = k2p::PCHN;
  wire signed [31:0] wADDC  = k2p::ADDC;
  wire signed [31:0] wACHN  = k2p::ACHN;
  wire        [31:0] q1, q2;
  k2_sub #(.SP(k2p::PW)) u1 (.q(q1));    // OVERRIDDEN — must still decline
  k2_sub u2 (.q(q2));                    // the DEFAULT
  assign o = {wPW, wPWC} ^ wPW63 ^ wPW63C ^ wSHL ^ wSHLC ^ {wWBH, wWBHC} ^
             {24'd0, wNU, wNUC} ^ {wNEG, wNEGC} ^ {wBIGM, wBIGMC} ^
             wBIGD ^ wBIGDC ^ {wENC, wPLAIN} ^ {wPCHN, wADDC} ^
             {wACHN, 32'd0} ^ {q1, q2};
endmodule

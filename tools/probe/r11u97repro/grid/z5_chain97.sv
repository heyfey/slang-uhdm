// r11u97 arm z5 — § chainStoreChecksTheInitializer97, THE CHAIN OVER A NAME
// WHOSE STORE AND WHOSE REDUCE DISAGREE.
//
// `red72Int64`'s NAME guard decides "is this store the initializer's value or
// an override?" by comparing the store against OUR OWN reduce — sound only
// while the two readings agree, which is exactly what the digit arms break.
// This arm crosses the three digit arms (r11u76's based leaf, r11u96's
// unsized decimal, LAW A's `'1`) with a CHAIN, and carries an OVERRIDDEN
// parameter and a defaulted PORT parameter as the live controls that must
// still decline.
package z5p;
  localparam int     U1MUL = '1 * 2;          // store 0xFFFFFFFE, reduce 2
  localparam int     U1CHN = U1MUL * 2;       // the chain — golden INT:4
  localparam int     U1CH2 = U1CHN - 1;       // two hops
  localparam int     U1CHS = U1MUL - 1;
  localparam longint SEP   = 4294967296 - 0;  // r11u96's LAW B, store 0
  localparam longint CHAIN = SEP - 0;         // r11v96's RV96-4
  localparam longint CHMUL = SEP * 2;
  localparam int     WB    = 4'd12 - 0;       // r11u76's based leaf, store 12
  localparam int     WBCHN = WB - 0;
  // ===== THE LIVE CONTROLS
  localparam int     PLAIN = 2 * 3;           // store and reduce agree
  localparam int     PCHN  = PLAIN * 2;       // golden INT:12
  localparam int     ADDC  = 1 + 2;
  localparam int     ACHN  = ADDC + 1;
endpackage
module z5_sub #(parameter int SP = 7) (output logic [31:0] q);
  localparam int SPCHN = SP - 1;              // a PORT parameter's chain
  assign q = SPCHN;
endmodule
module z5_chain97 (output logic [63:0] o);
  wire signed [31:0] wU1MUL = z5p::U1MUL;
  wire signed [31:0] wU1CHN = z5p::U1CHN;
  wire signed [31:0] wU1CH2 = z5p::U1CH2;
  wire signed [31:0] wU1CHS = z5p::U1CHS;
  wire signed [63:0] wSEP   = z5p::SEP;
  wire signed [63:0] wCHAIN = z5p::CHAIN;
  wire signed [63:0] wCHMUL = z5p::CHMUL;
  wire signed [31:0] wWB    = z5p::WB;
  wire signed [31:0] wWBCHN = z5p::WBCHN;
  wire signed [31:0] wPLAIN = z5p::PLAIN;
  wire signed [31:0] wPCHN  = z5p::PCHN;
  wire signed [31:0] wADDC  = z5p::ADDC;
  wire signed [31:0] wACHN  = z5p::ACHN;
  wire        [31:0] q1, q2;
  z5_sub #(.SP(z5p::U1MUL)) u1 (.q(q1));   // an OVERRIDDEN port parameter
  z5_sub u2 (.q(q2));                      // the DEFAULT
  assign o = {wU1MUL, wU1CHN} ^ {wU1CH2, wU1CHS} ^ wSEP ^ wCHAIN ^ wCHMUL ^
             {wWB, wWBCHN} ^ {wPLAIN, wPCHN} ^ {wADDC, wACHN} ^ {q1, q2};
endmodule

// r11v91 BREAK arm v3 — LAW B's PREDICATE ON EVERY NEGATIVE SHAPE THE FOLD
// SITE CAN SEE.  `neg91 = cv.integer().isSigned() && isNegative()`, and the
// site writes the value AND the const type.  Narrow signed types, the
// two's-complement corner, an unsigned-typed negative (declined), a negative
// reached through an operation, a const-function call (callSigned9 already
// true) and the POSITIVE controls.
package v3p;
  function automatic int fneg(input int a); return -a; endfunction
  localparam int                 NI   = -3;
  localparam bit signed [3:0]    NB4  = -3;        // a NARROW signed bit
  localparam logic signed [7:0]  NL8  = -3;
  localparam byte                NBY  = -3;
  localparam longint             NLL  = -3;
  localparam int                 NMIN = -2147483647;
  localparam                     NIMP = -3;        // implicit
  localparam int                 NOP  = 0 - 3;     // an operation
  localparam logic [7:0]         NU8  = -3;        // UNSIGNED type: 253
  localparam int                 NZ   = -0;        // negative zero
  localparam int                 NFC  = fneg(3);   // callSigned9 road
  localparam int                 PPOS = 3;         // the POSITIVE control
  localparam bit signed [3:0]    PB4  = 4'd3;      // narrow positive control
endpackage
module v3_negfold91 (output logic [63:0] o);
  wire signed [31:0] wNI   = v3p::NI;
  wire signed [31:0] wNB4  = v3p::NB4;
  wire signed [31:0] wNL8  = v3p::NL8;
  wire signed [31:0] wNBY  = v3p::NBY;
  wire signed [63:0] wNLL  = v3p::NLL;
  wire signed [31:0] wNMIN = v3p::NMIN;
  wire signed [31:0] wNIMP = v3p::NIMP;
  wire signed [31:0] wNOP  = v3p::NOP;
  wire signed [31:0] wNU8  = v3p::NU8;
  wire signed [31:0] wNZ   = v3p::NZ;
  wire signed [31:0] wNFC  = v3p::NFC;
  wire signed [31:0] wPPOS = v3p::PPOS;
  wire signed [31:0] wPB4  = v3p::PB4;
  assign o = {wNI, wNB4} ^ {wNL8, wNBY} ^ wNLL ^ {wNMIN, wNIMP} ^
             {wNOP, wNU8} ^ {wNZ, wNFC} ^ {wPPOS, wPB4};
endmodule

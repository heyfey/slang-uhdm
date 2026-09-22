// r11u94 arm q4 — THE NEGATIVE PACKAGE PARAMETER, r11u91's R2 and R3.  An
// UNSIGNED declared type over a negative initializer (golden keeps the
// negation's own signed value where our store has already wrapped it to the
// declared width) and NEGATIVE ZERO (golden's INT comes from the negation and
// not from the sign of the result).  Bases, operations, widths, the two
// POSITIVE controls and the landed law's own cells, read through the
// net-decl-assign road `nda91v.py` scores.
package q4p;
  localparam logic [7:0]  NU8  = -3;      // R2: golden INT:-3, ours UINT:253
  localparam logic [15:0] NU16 = -3;
  localparam bit   [3:0]  NUB4 = -3;
  localparam logic [31:0] NU32 = -3;
  localparam logic [7:0]  NUH  = -8'h3;   // a BASED negative, unsigned type
  localparam logic [7:0]  NUOP = 0 - 3;   // an OPERATION, unsigned type
  localparam int          NZ   = -0;      // R3: golden INT:0 ct7, ours UINT:0
  localparam logic [7:0]  NUZ  = -0;      // negative zero, unsigned type
  localparam int          NZP  =  0;      // the POSITIVE control
  localparam logic [7:0]  PU8  =  3;      // the POSITIVE control
  localparam int          NPAR = -(3);    // parenthesised
  localparam int          NDBL = -(-3);   // double negation: +3
  localparam int          NI   = -3;      // the LANDED law's cell
  localparam int          NIH  = -8'h3;   // signed type, based negative
endpackage
module q4_negpkg94 (output logic [63:0] o);
  wire signed [31:0] wNU8  = q4p::NU8;
  wire signed [31:0] wNU16 = q4p::NU16;
  wire signed [31:0] wNUB4 = q4p::NUB4;
  wire signed [31:0] wNU32 = q4p::NU32;
  wire signed [31:0] wNUH  = q4p::NUH;
  wire signed [31:0] wNUOP = q4p::NUOP;
  wire signed [31:0] wNZ   = q4p::NZ;
  wire signed [31:0] wNUZ  = q4p::NUZ;
  wire signed [31:0] wNZP  = q4p::NZP;
  wire signed [31:0] wPU8  = q4p::PU8;
  wire signed [31:0] wNPAR = q4p::NPAR;
  wire signed [31:0] wNDBL = q4p::NDBL;
  wire signed [31:0] wNI   = q4p::NI;
  wire signed [31:0] wNIH  = q4p::NIH;
  assign o = {wNU8, wNU16} ^ {wNUB4, wNU32} ^ {wNUH, wNUOP} ^ {wNZ, wNUZ} ^
             {wNZP, wPU8} ^ {wNPAR, wNDBL} ^ {wNI, wNIH};
endmodule

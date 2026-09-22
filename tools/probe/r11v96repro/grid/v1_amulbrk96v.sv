// r11v96 VERIFIER arm v1 — LAW A BREAKERS.  Shapes the mult/div/mod gate
// reaches that the implementer's y1 does not hold: chained operators, a
// system-function operand, an enum operand, an unbased-unsized operand, a
// SIGNED-narrow declaration whose store has already wrapped, a real operand,
// an overridden package parameter, and the unary-minus-over-a-product face.
package v1p;
  typedef enum int { EA = 3, EB = 5 } e_t;
  localparam int           SMUL  = 2 * 3 * 4;       // chained mult
  localparam int           MDIVC = 100 / 5 / 2;     // chained div
  localparam int           MMIX  = 2 * 3 + 1;       // mult under an ADD
  localparam int           MMIX2 = 1 + 2 * 3;       // the same, other order
  localparam int           MSUBM = 10 - 2 * 3;      // mult under a SUBTRACT
  localparam int           MNEGP = -(2 * 3);        // unary minus over a mult
  localparam int           MSYS  = $clog2(16) * 2;  // a system call operand
  localparam int           MENUM = EA * 2;          // an ENUM operand
  localparam int           MUNB  = '1 * 2;          // unbased-unsized operand
  localparam logic signed [3:0] MSN4 = 3 * 3;       // signed narrow, wraps
  localparam logic signed [7:0] MSN8 = 20 * 20;     // signed narrow, wraps
  localparam int           MSTRW = 8'sd100 * 3;     // signed based leaf
  localparam int           MODNG = 7 % (-4);        // a NEGATIVE divisor
  localparam int           MDVNG = 7 / (-4);
  localparam int           MDMIN = -2147483648 / 1; // int min over one
  localparam int           MREAL = int'(2 * 3.0);   // a REAL operand, cast
  localparam int           MCOND = (1 ? 2 : 3) * 4; // a ternary operand
  localparam int           MSELF = SMUL % 7;        // a CHAIN under mod
  localparam int           CPLUS = 3 + 4;           // control
  localparam int           CSHR  = 32 >> 2;         // control
  localparam int           CAND  = 12 & 10;         // control: bitwise AND
  localparam int           COR   = 12 | 3;          // control: bitwise OR
  localparam int           CXOR  = 12 ^ 10;         // control: XOR
  localparam int           CCMP  = (3 < 4);         // control: comparison
endpackage
module v1_sub #(parameter int PV = 7) (output logic [31:0] q);
  assign q = PV;
endmodule
module v1_amulbrk96v (output logic [63:0] o);
  wire signed [31:0] wSMUL  = v1p::SMUL;
  wire signed [31:0] wMDIVC = v1p::MDIVC;
  wire signed [31:0] wMMIX  = v1p::MMIX;
  wire signed [31:0] wMMIX2 = v1p::MMIX2;
  wire signed [31:0] wMSUBM = v1p::MSUBM;
  wire signed [31:0] wMNEGP = v1p::MNEGP;
  wire signed [31:0] wMSYS  = v1p::MSYS;
  wire signed [31:0] wMENUM = v1p::MENUM;
  wire signed [31:0] wMUNB  = v1p::MUNB;
  wire signed [31:0] wMSN4  = v1p::MSN4;
  wire signed [31:0] wMSN8  = v1p::MSN8;
  wire signed [31:0] wMSTRW = v1p::MSTRW;
  wire signed [31:0] wMODNG = v1p::MODNG;
  wire signed [31:0] wMDVNG = v1p::MDVNG;
  wire signed [31:0] wMDMIN = v1p::MDMIN;
  wire signed [31:0] wMREAL = v1p::MREAL;
  wire signed [31:0] wMCOND = v1p::MCOND;
  wire signed [31:0] wMSELF = v1p::MSELF;
  wire signed [31:0] wCPLUS = v1p::CPLUS;
  wire signed [31:0] wCSHR  = v1p::CSHR;
  wire signed [31:0] wCAND  = v1p::CAND;
  wire signed [31:0] wCOR   = v1p::COR;
  wire signed [31:0] wCXOR  = v1p::CXOR;
  wire signed [31:0] wCCMP  = v1p::CCMP;
  wire        [31:0] q1, q2;
  v1_sub #(.PV(v1p::SMUL)) u1 (.q(q1));
  v1_sub u2 (.q(q2));
  assign o = {wSMUL, wMDIVC} ^ {wMMIX, wMMIX2} ^ {wMSUBM, wMNEGP} ^
             {wMSYS, wMENUM} ^ {wMUNB, wMSN4} ^ {wMSN8, wMSTRW} ^
             {wMODNG, wMDVNG} ^ {wMDMIN, wMREAL} ^ {wMCOND, wMSELF} ^
             {wCPLUS, wCSHR} ^ {wCAND, wCOR} ^ {wCXOR, wCCMP} ^ {q1, q2};
endmodule

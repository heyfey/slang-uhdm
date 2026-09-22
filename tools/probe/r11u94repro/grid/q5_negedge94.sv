// r11u94 arm q5 — THE NEGATIVE FOLD'S OWN EDGES: is golden's `INT:` the SIGN
// OF THE STORED VALUE, the SIGN-EXTENSION of the declared width, or the
// NEGATION IN THE SOURCE?  The three readings agree on `-3` and disagree
// here.  `XFF`/`XD`/`XB` hold the SAME stored 253 as `q4p::NU8` with NO
// negation written; `XSUB` reaches it through a subtraction; `XBIG` and
// `XWRAP` overflow the declared width so a sign-extension answer and a
// 64-bit-reduce answer differ; `XADD`/`XMUL`/`XDIV` are operations with NO
// negation at all; `XNEGP` is a negation whose result is POSITIVE under an
// unsigned declaration.
package q5p;
  localparam logic [7:0]  XFF   = 8'hff;      // 253-class stored value, NO minus
  localparam logic [7:0]  XD    = 253;
  localparam logic [7:0]  XB    = 8'b11111101;
  localparam logic [7:0]  XSUB  = 5 - 8;      // negative via SUBTRACTION
  localparam logic [7:0]  XBIG  = -300;       // overflows the declared width
  localparam logic [7:0]  XWRAP = -259;       // -259 & 8'hff == 253
  localparam int          XADD  = 1 + 2;      // an operation, no negation
  localparam int          XMUL  = 2 * 3;
  localparam int          XDIV  = 6 / 2;
  localparam logic [7:0]  XNEGP = -(-3);      // negation, POSITIVE result
  localparam logic [7:0]  XADDU = 1 + 2;
  localparam int          XZSUB = 0 - 0;      // a subtraction yielding zero
  localparam logic [7:0]  XSHL  = -1 <<< 1;   // a shift over a negation
  localparam int          XCMP  = ~0;         // bitwise NOT: -1
endpackage
module q5_negedge94 (output logic [63:0] o);
  wire signed [31:0] wXFF   = q5p::XFF;
  wire signed [31:0] wXD    = q5p::XD;
  wire signed [31:0] wXB    = q5p::XB;
  wire signed [31:0] wXSUB  = q5p::XSUB;
  wire signed [31:0] wXBIG  = q5p::XBIG;
  wire signed [31:0] wXWRAP = q5p::XWRAP;
  wire signed [31:0] wXADD  = q5p::XADD;
  wire signed [31:0] wXMUL  = q5p::XMUL;
  wire signed [31:0] wXDIV  = q5p::XDIV;
  wire signed [31:0] wXNEGP = q5p::XNEGP;
  wire signed [31:0] wXADDU = q5p::XADDU;
  wire signed [31:0] wXZSUB = q5p::XZSUB;
  wire signed [31:0] wXSHL  = q5p::XSHL;
  wire signed [31:0] wXCMP  = q5p::XCMP;
  assign o = {wXFF, wXD} ^ {wXB, wXSUB} ^ {wXBIG, wXWRAP} ^ {wXADD, wXMUL} ^
             {wXDIV, wXNEGP} ^ {wXADDU, wXZSUB} ^ {wXSHL, wXCMP};
endmodule

// r11u94 arm q6 — the minus family's WIDTH corner and its POSITIVE results.
// Does the producer's `vpiMinusOp` / `vpiSubOp` arm mask its int64 answer by
// the DECLARED width (a signed declaration narrower than the reduce) and does
// it mint `INT:` for a SUBTRACTION whose result is POSITIVE — the shape a
// real design writes as `localparam W = N - 1`?  The cast and the conditional
// are the two top-level shapes the law must decline.
package q6p;
  localparam byte               XBY    = -300;      // signed decl, OVERFLOW
  localparam logic signed [7:0] XSN    = -300;
  localparam shortint           XSH2   = -70000;
  localparam longint            XLL    = -3;
  localparam int                XSUBP  = 8 - 1;     // POSITIVE subtraction
  localparam logic [7:0]        XSUBPU = 8 - 1;
  localparam logic [15:0]       XM1    = 16 - 1;    // the real-design shape
  localparam int                XSUBN  = XSUBP - 9; // over a NAME
  localparam logic [7:0]        XNAME  = XSUBP - 9;
  localparam int                XPAREN = (5 - 8);   // parenthesised
  localparam logic [7:0]        XCAST  = 8'(5 - 8); // a CAST on top
  localparam int                XTERN  = 1 ? -3 : 4;// a CONDITIONAL on top
  localparam int                XSUBZ  = 3 - 3;     // a ZERO subtraction
  localparam logic [7:0]        XNEGN  = -XSUBP;    // negation over a NAME
endpackage
module q6_negwid94 (output logic [63:0] o);
  wire signed [31:0] wXBY    = q6p::XBY;
  wire signed [31:0] wXSN    = q6p::XSN;
  wire signed [31:0] wXSH2   = q6p::XSH2;
  wire signed [63:0] wXLL    = q6p::XLL;
  wire signed [31:0] wXSUBP  = q6p::XSUBP;
  wire signed [31:0] wXSUBPU = q6p::XSUBPU;
  wire signed [31:0] wXM1    = q6p::XM1;
  wire signed [31:0] wXSUBN  = q6p::XSUBN;
  wire signed [31:0] wXNAME  = q6p::XNAME;
  wire signed [31:0] wXPAREN = q6p::XPAREN;
  wire signed [31:0] wXCAST  = q6p::XCAST;
  wire signed [31:0] wXTERN  = q6p::XTERN;
  wire signed [31:0] wXSUBZ  = q6p::XSUBZ;
  wire signed [31:0] wXNEGN  = q6p::XNEGN;
  assign o = {wXBY, wXSN} ^ {wXSH2, wXSUBP} ^ wXLL ^ {wXSUBPU, wXM1} ^
             {wXSUBN, wXNAME} ^ {wXPAREN, wXCAST} ^ {wXTERN, wXSUBZ} ^
             {wXNEGN, wXSUBP};
endmodule

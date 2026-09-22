// r11v97 VERIFIER arm k3 — LAW B's OPERAND-MINT predicate on shapes the
// implementer's z2 does not carry: a TWO-HOP name, a unary minus child, a
// double unary minus, a based DECIMAL on the RIGHT only, a TERNARY child, an
// explicit CAST child, a system call over an INT-minting argument, a wide add
// whose reduce and whose store disagree, a 64-bit add, and a deep add chain.
package k3p;
  localparam int     XMUL2 = 2 * 3;
  localparam int     XNAME = XMUL2;          // a NAME over a NAME
  localparam int     XADD  = 1 + 2;
  localparam int     ANM2  = XNAME + 1;      // two hops to the mint
  localparam int     AUM   = (-3) + 1;
  localparam int     AUMP  = (-(-3)) + 1;
  localparam int     AHEXD = 8'h10 + 8'd1;   // RIGHT operand is the DecConst
  localparam int     ADECL = 8'd10 + 8'h01;  // LEFT operand is the DecConst
  localparam int     ADD0  = 0 + 0;
  localparam int     ASHFT = (1 << 3) + (2 * 2);
  localparam int     APOW2 = 2 ** 3 + 1;
  localparam int     ATERN = (1 ? 2 * 3 : 4) + 1;
  localparam int     ACAST = int'(2 * 3) + 1;
  localparam int     ACLOG = $clog2(2 * 3) + 1;
  localparam int     ANEGL = (0 - 1) + 1;
  localparam int     AOVF  = 2147483647 * 2 + 2;
  localparam longint ALON  = 4294967296 - 0 + 1;
  localparam int     ADEEPN = ((((((1 + 1) + 1) + 1) + 1) + 1)) + (2 * 3);
  localparam int     AADDNM = XADD + XMUL2;  // one UINT child, one INT child
  localparam int     AADDBOTH = XMUL2 + XMUL2;
  // ===== THE LIVE NEGATIVE CONTROLS
  localparam int     CADD  = 1 + 2;
  localparam int     CANM2 = XADD + 1;
  localparam int     CDEEP = ((1 + 2) + 3) + 4;
endpackage
module k3_addop94v (output logic [63:0] o);
  wire signed [31:0] wXMUL2 = k3p::XMUL2;
  wire signed [31:0] wXNAME = k3p::XNAME;
  wire signed [31:0] wANM2  = k3p::ANM2;
  wire signed [31:0] wAUM   = k3p::AUM;
  wire signed [31:0] wAUMP  = k3p::AUMP;
  wire signed [31:0] wAHEXD = k3p::AHEXD;
  wire signed [31:0] wADECL = k3p::ADECL;
  wire signed [31:0] wADD0  = k3p::ADD0;
  wire signed [31:0] wASHFT = k3p::ASHFT;
  wire signed [31:0] wAPOW2 = k3p::APOW2;
  wire signed [31:0] wATERN = k3p::ATERN;
  wire signed [31:0] wACAST = k3p::ACAST;
  wire signed [31:0] wACLOG = k3p::ACLOG;
  wire signed [31:0] wANEGL = k3p::ANEGL;
  wire signed [31:0] wAOVF  = k3p::AOVF;
  wire signed [63:0] wALON  = k3p::ALON;
  wire signed [31:0] wADEEP = k3p::ADEEPN;
  wire signed [31:0] wAADNM = k3p::AADDNM;
  wire signed [31:0] wAADBO = k3p::AADDBOTH;
  wire signed [31:0] wCADD  = k3p::CADD;
  wire signed [31:0] wCANM2 = k3p::CANM2;
  wire signed [31:0] wCDEEP = k3p::CDEEP;
  assign o = {wXMUL2, wXNAME} ^ {wANM2, wAUM} ^ {wAUMP, wAHEXD} ^
             {wADECL, wADD0} ^ {wASHFT, wAPOW2} ^ {wATERN, wACAST} ^
             {wACLOG, wANEGL} ^ {wAOVF, wADEEP} ^ wALON ^
             {wAADNM, wAADBO} ^ {wCADD, wCANM2} ^ {wCDEEP, 32'd0};
endmodule

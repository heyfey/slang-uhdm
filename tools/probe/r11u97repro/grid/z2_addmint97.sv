// r11u97 arm z2 — LAW B: THE INT MINT PROPAGATES THROUGH THE PARENT.
// `reduceExpr`'s `vpiAddOp` arm (ExprEval.cpp:3260-3329) is the ONLY arm that
// reads its REDUCED operands' const types: `unsignedOperation` starts true and
// is cleared by any operand constant whose `VpiConstType()` is `vpiIntConst`,
// `vpiStringConst`, `vpiRealConst` or `vpiDecConst`.  So an INT-minting
// sub-expression carries the mint UPWARD and `2*3 + 1` is `INT:7` where
// `1 + 2` is `UINT:3`.  This arm crosses every INT-minting child with the `+`
// parent, at three depths, on both sides, and carries the UINT-minting
// children as the live controls.
package z2p;
  typedef enum int { EA = 3, EB = 5 } e_t;
  localparam int XMUL   = 2 * 3;            // an INT-minted NAME
  localparam int XADD   = 1 + 2;            // a UINT-minted NAME
  localparam int XSUB   = 8 - 1;            // a sub-minted NAME
  localparam int XPOW   = 2 ** 3;           // a power-minted NAME
  localparam int APOWL  = (2 ** 3) + 1;     // the POWER child — R1's road
  localparam int ADECL  = 8'd10 + 1;        // a BASED-DECIMAL leaf child
  localparam int AENUM  = EA + 1;           // an ENUM operand
  localparam int AZERO  = (0 - 0) + 1;      // an INT child whose VALUE is 0
  localparam int ANAMES = XSUB + 1;         // a NAME over the sub road
  localparam int ANAMEP = XPOW + 1;         // a NAME over the power road
  localparam int ATWO   = (2 * 3) + (4 - 1);// BOTH operands INT-minting
  localparam int APLUSU = (+5) + 1;         // a unary PLUS child
  localparam int ADECS  = 8'sd10 + 1;       // a SIGNED based-decimal leaf
  localparam int ADECB  = 4'b1010 + 1;      // a BINARY based leaf
  localparam int ADECO  = 8'o12 + 1;        // an OCTAL based leaf
  localparam int ADECW  = 40'd10 + 1;       // a WIDE based-decimal leaf
  localparam int MMIX   = 2 * 3 + 1;        // mult LEFT under add
  localparam int MMIX2  = 1 + 2 * 3;        // mult RIGHT under add
  localparam int ASUBL  = (8 - 1) + 1;      // sub under add
  localparam int ASUBR  = 1 + (8 - 1);
  localparam int ADIVL  = (6 / 2) + 1;      // div under add
  localparam int AMODL  = (7 % 4) + 1;      // mod under add
  localparam int ANEGL  = (-2) + 1;         // unary minus under add
  localparam int ANEGR  = 1 + (-2);
  localparam int ADEEP2 = ((2 * 3) + 1) + 1;// add under add, inner INT
  localparam int ADEEP3 = (((2 * 3) + 1) + 1) + 1;
  localparam int ANEST  = (1 + (2 * 3)) + 1;// the INT child one level down
  localparam int ANAMEL = XMUL + 1;         // a NAME holding an INT-minted value
  localparam int ANAMER = 1 + XMUL;
  localparam int ANAME2 = XADD + 1;         // a NAME holding a UINT-minted one
  localparam int APARL  = ((2 * 3)) + 1;    // parenthesised child
  localparam int AMULTOP = (1 + 2) * 3;     // the TOP is a mult — already INT
  localparam int ASUBTOP = (1 + 2) - 1;     // the TOP is a sub — already INT
  // ===== THE LIVE CONTROLS — a UINT-minting child leaves the add unsigned.
  localparam int CADD   = 1 + 2;
  localparam int CADD3  = (1 + 2) + 3;      // add under add, both UINT
  localparam int CSHLA  = (1 << 3) + 1;     // shift child, UINT mint
  localparam int CSHRA  = (32 >> 2) + 1;
  localparam int CANDA  = (12 & 10) + 1;    // bit-and child, UINT mint
  localparam int CORA   = (12 | 3) + 1;
  localparam int CXORA  = (12 ^ 10) + 1;
  localparam int CLGA   = (1 && 1) + 1;     // logical child, UINT mint
  localparam int CLITA  = 4 + 1;            // two plain literals
  localparam int CHEXA  = 8'h10 + 1;        // a based leaf child
  localparam int CSYSA  = $clog2(16) + 1;   // a system call child
  localparam int CCNDA  = (1 ? 2 : 3) + 1;  // a ternary child
  localparam int CMULP  = 2 * 3;            // the landed mult law, untouched
  localparam int CSUBP  = 8 - 1;            // the landed minus law, untouched
endpackage
module z2_addmint97 (output logic [63:0] o);
  wire signed [31:0] wXMUL    = z2p::XMUL;
  wire signed [31:0] wXADD    = z2p::XADD;
  wire signed [31:0] wXSUB    = z2p::XSUB;
  wire signed [31:0] wXPOW    = z2p::XPOW;
  wire signed [31:0] wAPOWL   = z2p::APOWL;
  wire signed [31:0] wADECL   = z2p::ADECL;
  wire signed [31:0] wAENUM   = z2p::AENUM;
  wire signed [31:0] wAZERO   = z2p::AZERO;
  wire signed [31:0] wANAMES  = z2p::ANAMES;
  wire signed [31:0] wANAMEP  = z2p::ANAMEP;
  wire signed [31:0] wATWO    = z2p::ATWO;
  wire signed [31:0] wAPLUSU  = z2p::APLUSU;
  wire signed [31:0] wADECS   = z2p::ADECS;
  wire signed [31:0] wADECB   = z2p::ADECB;
  wire signed [31:0] wADECO   = z2p::ADECO;
  wire signed [31:0] wADECW   = z2p::ADECW;
  wire signed [31:0] wMMIX    = z2p::MMIX;
  wire signed [31:0] wMMIX2   = z2p::MMIX2;
  wire signed [31:0] wASUBL   = z2p::ASUBL;
  wire signed [31:0] wASUBR   = z2p::ASUBR;
  wire signed [31:0] wADIVL   = z2p::ADIVL;
  wire signed [31:0] wAMODL   = z2p::AMODL;
  wire signed [31:0] wANEGL   = z2p::ANEGL;
  wire signed [31:0] wANEGR   = z2p::ANEGR;
  wire signed [31:0] wADEEP2  = z2p::ADEEP2;
  wire signed [31:0] wADEEP3  = z2p::ADEEP3;
  wire signed [31:0] wANEST   = z2p::ANEST;
  wire signed [31:0] wANAMEL  = z2p::ANAMEL;
  wire signed [31:0] wANAMER  = z2p::ANAMER;
  wire signed [31:0] wANAME2  = z2p::ANAME2;
  wire signed [31:0] wAPARL   = z2p::APARL;
  wire signed [31:0] wAMULTOP = z2p::AMULTOP;
  wire signed [31:0] wASUBTOP = z2p::ASUBTOP;
  wire signed [31:0] wCADD    = z2p::CADD;
  wire signed [31:0] wCADD3   = z2p::CADD3;
  wire signed [31:0] wCSHLA   = z2p::CSHLA;
  wire signed [31:0] wCSHRA   = z2p::CSHRA;
  wire signed [31:0] wCANDA   = z2p::CANDA;
  wire signed [31:0] wCORA    = z2p::CORA;
  wire signed [31:0] wCXORA   = z2p::CXORA;
  wire signed [31:0] wCLGA    = z2p::CLGA;
  wire signed [31:0] wCLITA   = z2p::CLITA;
  wire signed [31:0] wCHEXA   = z2p::CHEXA;
  wire signed [31:0] wCSYSA   = z2p::CSYSA;
  wire signed [31:0] wCCNDA   = z2p::CCNDA;
  wire signed [31:0] wCMULP   = z2p::CMULP;
  wire signed [31:0] wCSUBP   = z2p::CSUBP;
  assign o = {wXMUL, wXADD} ^ {wMMIX, wMMIX2} ^ {wASUBL, wASUBR} ^
             {wADIVL, wAMODL} ^ {wANEGL, wANEGR} ^ {wADEEP2, wADEEP3} ^
             {wANEST, wANAMEL} ^ {wANAMER, wANAME2} ^ {wAPARL, wAMULTOP} ^
             {wASUBTOP, wCADD} ^ {wCADD3, wCSHLA} ^ {wCSHRA, wCANDA} ^
             {wCORA, wCXORA} ^ {wCLGA, wCLITA} ^ {wCHEXA, wCSYSA} ^
             {wCCNDA, wCMULP} ^ {wCSUBP, wXMUL} ^ {wXSUB, wXPOW} ^
             {wAPOWL, wADECL} ^ {wAENUM, wAZERO} ^ {wANAMES, wANAMEP} ^
             {wATWO, wAPLUSU} ^ {wADECS, wADECB} ^ {wADECO, wADECW};
endmodule

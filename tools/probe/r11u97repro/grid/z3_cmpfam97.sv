// r11u97 arm z3 — LAW C: THE COMPARISON FAMILY.
// `reduceExpr` routes `vpiLeOp/vpiLtOp/vpiGeOp/vpiGtOp/vpiNeqOp/vpiEqOp` to
// `reduceCompOp` (ExprEval.cpp:3173-3182 -> :1639), which mints
// `BIN:<0|1>` with `VpiSize(1)` and `vpiBinaryConst` — a ONE-BIT answer.  The
// logical arms (`&&`, `||`) are NOT on that road: they mint `UINT:` with
// `VpiSize(64)` at :3369/:3387.  This arm measures the whole family, the
// logical controls, and what the one-bit answer becomes at each declared
// width and signedness.
package z3p;
  typedef int td_int_t;
  localparam int CLT   = (3 < 4);
  // ===== the DECLARATION-KIND crossing of the same true comparison
  localparam                    DIMP  = (3 < 4);   // implicit — `int` by LRM
  localparam integer            DINTG = (3 < 4);
  localparam int unsigned       DIU   = (3 < 4);
  localparam logic signed [31:0] DLS32 = (3 < 4);
  localparam logic [31:0]       DL32  = (3 < 4);
  localparam bit [31:0]         DB32  = (3 < 4);
  localparam bit signed [31:0]  DBS32 = (3 < 4);
  localparam td_int_t           DTD   = (3 < 4);   // a TYPEDEF of int
  localparam int                DIMPF = (4 < 3);   // the false face, `int`
  // ===== the SIGNEDNESS edge: a 64-bit all-ones operand.  `reduceCompOp`
  // assigns `get_uvalue`'s answer to an `int64_t` and compares SIGNED, so it
  // reads `64'hFFFF_FFFF_FFFF_FFFF` as -1 where slang reads it as 2^64-1.
  localparam int DU64  = (64'hFFFF_FFFF_FFFF_FFFF > 1);
  localparam int DU64E = (64'hFFFF_FFFF_FFFF_FFFF < 1);
  localparam int DNAME = (CLT < 2);                // a NAME operand
  localparam int EMUL  = (3 < 4) * 2;              // a comparison under `*`
  localparam int ESUB  = (3 < 4) - 1;              // a comparison under `-`
  localparam int ENEG  = -(3 < 4);                 // a comparison negated
  localparam int EU1   = ('1 < 2);                 // LAW A inside LAW C
  localparam int CLTF  = (4 < 3);
  localparam int CGT   = (4 > 3);
  localparam int CGTF  = (3 > 4);
  localparam int CLE   = (3 <= 3);
  localparam int CLEF  = (4 <= 3);
  localparam int CGE   = (3 >= 3);
  localparam int CGEF  = (3 >= 4);
  localparam int CEQ   = (3 == 3);
  localparam int CEQF  = (3 == 4);
  localparam int CNE   = (3 != 4);
  localparam int CNEF  = (3 != 3);
  localparam int CLTN  = (-1 < 0);          // signed operands
  localparam int CLTC  = (CLT < 2);         // a NAME operand
  localparam int CLTX  = (2 * 3 < 7);       // an INT-minting operand
  // ===== the declared-type crossing of ONE true comparison
  localparam longint        QLT64 = (3 < 4);
  localparam logic [7:0]    QLTU8 = (3 < 4);
  localparam logic signed [7:0] QLTS8 = (3 < 4);
  localparam bit            QLTB1 = (3 < 4);
  localparam logic          QLTL1 = (3 < 4);
  localparam byte           QLTBY = (3 < 4);
  // ===== THE LIVE CONTROLS — not on `reduceCompOp`'s road.
  localparam int CAND  = (1 && 1);
  localparam int CANDF = (1 && 0);
  localparam int COR   = (0 || 1);
  localparam int CNOT  = (!0);              // vpiNotOp, its own arm
  localparam int CNOTT = (!3);
  localparam int CCEQ  = (3 === 3);         // the CASE equality, its own arm
  localparam int CCNE  = (3 !== 3);
  localparam int CTERN = (3 < 4) ? 5 : 6;   // a comparison UNDER a ternary
  localparam int CADDC = (3 < 4) + 1;       // a comparison UNDER an add
  localparam int CCHN  = CLT;               // a CHAIN over a comparison
  localparam int CSUB  = 8 - 1;             // the landed minus law
  localparam int CMUL  = 2 * 3;             // the landed mult law
  localparam int CADD  = 1 + 2;             // the `+` control
endpackage
module z3_cmpfam97 (output logic [63:0] o);
  wire signed [31:0] wCLT   = z3p::CLT;
  wire signed [31:0] wDIMP  = z3p::DIMP;
  wire signed [31:0] wDINTG = z3p::DINTG;
  wire signed [31:0] wDIU   = z3p::DIU;
  wire signed [31:0] wDLS32 = z3p::DLS32;
  wire signed [31:0] wDL32  = z3p::DL32;
  wire signed [31:0] wDB32  = z3p::DB32;
  wire signed [31:0] wDBS32 = z3p::DBS32;
  wire signed [31:0] wDTD   = z3p::DTD;
  wire signed [31:0] wDIMPF = z3p::DIMPF;
  wire signed [31:0] wDU64  = z3p::DU64;
  wire signed [31:0] wDU64E = z3p::DU64E;
  wire signed [31:0] wDNAME = z3p::DNAME;
  wire signed [31:0] wEMUL  = z3p::EMUL;
  wire signed [31:0] wESUB  = z3p::ESUB;
  wire signed [31:0] wENEG  = z3p::ENEG;
  wire signed [31:0] wEU1   = z3p::EU1;
  wire signed [31:0] wCLTF  = z3p::CLTF;
  wire signed [31:0] wCGT   = z3p::CGT;
  wire signed [31:0] wCGTF  = z3p::CGTF;
  wire signed [31:0] wCLE   = z3p::CLE;
  wire signed [31:0] wCLEF  = z3p::CLEF;
  wire signed [31:0] wCGE   = z3p::CGE;
  wire signed [31:0] wCGEF  = z3p::CGEF;
  wire signed [31:0] wCEQ   = z3p::CEQ;
  wire signed [31:0] wCEQF  = z3p::CEQF;
  wire signed [31:0] wCNE   = z3p::CNE;
  wire signed [31:0] wCNEF  = z3p::CNEF;
  wire signed [31:0] wCLTN  = z3p::CLTN;
  wire signed [31:0] wCLTC  = z3p::CLTC;
  wire signed [31:0] wCLTX  = z3p::CLTX;
  wire signed [63:0] wQLT64 = z3p::QLT64;
  wire        [7:0]  wQLTU8 = z3p::QLTU8;
  wire signed [7:0]  wQLTS8 = z3p::QLTS8;
  wire               wQLTB1 = z3p::QLTB1;
  wire               wQLTL1 = z3p::QLTL1;
  wire signed [7:0]  wQLTBY = z3p::QLTBY;
  wire        [31:0] wCLTU  = z3p::CLT;     // the same cell, UNSIGNED reader
  wire signed [31:0] wCAND  = z3p::CAND;
  wire signed [31:0] wCANDF = z3p::CANDF;
  wire signed [31:0] wCOR   = z3p::COR;
  wire signed [31:0] wCNOT  = z3p::CNOT;
  wire signed [31:0] wCNOTT = z3p::CNOTT;
  wire signed [31:0] wCCEQ  = z3p::CCEQ;
  wire signed [31:0] wCCNE  = z3p::CCNE;
  wire signed [31:0] wCTERN = z3p::CTERN;
  wire signed [31:0] wCADDC = z3p::CADDC;
  wire signed [31:0] wCCHN  = z3p::CCHN;
  wire signed [31:0] wCSUB  = z3p::CSUB;
  wire signed [31:0] wCMUL  = z3p::CMUL;
  wire signed [31:0] wCADD  = z3p::CADD;
  assign o = {wCLT, wCLTF} ^ {wCGT, wCGTF} ^ {wCLE, wCLEF} ^ {wCGE, wCGEF} ^
             {wCEQ, wCEQF} ^ {wCNE, wCNEF} ^ {wCLTN, wCLTC} ^ {wCLTX, wCLTU} ^
             wQLT64 ^ {24'd0, wQLTU8, 24'd0, wQLTS8} ^
             {31'd0, wQLTB1, 31'd0, wQLTL1} ^ {24'd0, wQLTBY, 32'd0} ^
             {wCAND, wCANDF} ^ {wCOR, wCNOT} ^ {wCNOTT, wCCEQ} ^
             {wCCNE, wCTERN} ^ {wCADDC, wCCHN} ^ {wCSUB, wCMUL} ^
             {wCADD, wCLT} ^ {wDIMP, wDINTG} ^ {wDIU, wDLS32} ^
             {wDL32, wDB32} ^ {wDBS32, wDTD} ^ {wDIMPF, wDU64} ^
             {wDU64E, wDNAME} ^ {wEMUL, wESUB} ^ {wENEG, wEU1};
endmodule

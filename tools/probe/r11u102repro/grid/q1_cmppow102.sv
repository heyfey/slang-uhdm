// r11u102 arm q1 — LAW A (RV100-3): a COMPARISON as the OPERAND of every
// landed INT-minting operator.  `reduceCompOp` mints `BIN:<0|1>` sz1 and the
// parent arm reads it with `get_value`, so the parent's INT mint stands.
package q1p;
  localparam int     CPC    = (3 < 4) ** 3;
  localparam int     CPCR   = 3 ** (3 < 4);
  localparam int     CPCF   = (4 < 3) ** 3;
  localparam int     CPCF0  = 3 ** (4 < 3);
  localparam int     CPCE   = (3 == 3) ** 5;
  localparam int     CPCN0  = (3 != 3) ** 0;
  localparam int     CPCC   = (3 < 4) ** (3 < 4);
  localparam int     CPCG   = (4 > 3) ** 2;
  localparam int     CPCGE  = (3 >= 4) ** 2;
  localparam int     CPCLE  = 2 ** (3 <= 4);
  localparam longint CPCL   = (3 < 4) ** 40;
  localparam longint CPC2L  = 2 ** (3 < 4);
  localparam logic [7:0] CPC8 = (3 < 4) ** 3;
  localparam byte    CPCBY  = 5 ** (3 < 4);
  localparam int     CPCP   = ((3 < 4)) ** 3;
  localparam int     CPCX   = (2 * 3 < 7) ** 3;
  localparam int     CPCU   = (64'hFFFF_FFFF_FFFF_FFFF > 1) ** 3;
  localparam int     CPCUR  = 2 ** (64'hFFFF_FFFF_FFFF_FFFF < 1);
  localparam int     CPCT   = ('1 < 2) ** 3;
  localparam int     CMC    = (3 < 4) * 3;
  localparam int     CMCR   = 3 * (3 < 4);
  localparam int     CMCF   = (4 < 3) * 3;
  localparam int     CDC    = (3 < 4) / 1;
  localparam int     CDCR   = 6 / (3 < 4);
  localparam int     CMOD   = (3 < 4) % 2;
  localparam int     CMODR  = 7 % (3 < 4);
  localparam int     CSC    = (3 < 4) - 0;
  localparam int     CSCR   = 5 - (3 < 4);
  localparam int     CSCF   = 5 - (4 < 3);
  localparam int     CNEG   = -(3 < 4);
  localparam int     CNEGF  = -(4 < 3);
  localparam int     CAC    = (3 < 4) + 1;
  localparam int     CACR   = 1 + (3 < 4);
  localparam int     CAMC   = (3 < 4) + (2 * 3);
  localparam int     CAMCR  = (2 * 3) + (3 < 4);
  localparam int     CAPC   = (3 < 4) + (2 ** 3);
  localparam longint CMCL   = (3 < 4) * 4294967296;
  localparam int     CDEEP  = ((3 < 4) * 2) ** 3;
  localparam int     CLT    = (3 < 4);
  localparam int     CPNAME = CLT ** 3;
  localparam int     CPCEQ  = (3 === 3) ** 3;
  localparam int     CPLAND = (1 && 1) ** 3;
  localparam int     CPNOT  = (!0) ** 3;
  localparam int     CPTERN = (1 ? 2 : 3) ** 3;
  // controls
  localparam int     CPOW   = 2 ** 3;
  localparam int     CMUL   = 2 * 3;
  localparam int     CADD   = 1 + 2;
endpackage
module q1_cmppow102 (output logic [63:0] o);
  wire signed [63:0] wCPC    = q1p::CPC;
  wire signed [63:0] wCPCR   = q1p::CPCR;
  wire signed [63:0] wCPCF   = q1p::CPCF;
  wire signed [63:0] wCPCF0  = q1p::CPCF0;
  wire signed [63:0] wCPCE   = q1p::CPCE;
  wire signed [63:0] wCPCN0  = q1p::CPCN0;
  wire signed [63:0] wCPCC   = q1p::CPCC;
  wire signed [63:0] wCPCG   = q1p::CPCG;
  wire signed [63:0] wCPCGE  = q1p::CPCGE;
  wire signed [63:0] wCPCLE  = q1p::CPCLE;
  wire signed [63:0] wCPCL   = q1p::CPCL;
  wire signed [63:0] wCPC2L  = q1p::CPC2L;
  wire signed [63:0] wCPC8   = q1p::CPC8;
  wire signed [63:0] wCPCBY  = q1p::CPCBY;
  wire signed [63:0] wCPCP   = q1p::CPCP;
  wire signed [63:0] wCPCX   = q1p::CPCX;
  wire signed [63:0] wCPCU   = q1p::CPCU;
  wire signed [63:0] wCPCUR  = q1p::CPCUR;
  wire signed [63:0] wCPCT   = q1p::CPCT;
  wire signed [63:0] wCMC    = q1p::CMC;
  wire signed [63:0] wCMCR   = q1p::CMCR;
  wire signed [63:0] wCMCF   = q1p::CMCF;
  wire signed [63:0] wCDC    = q1p::CDC;
  wire signed [63:0] wCDCR   = q1p::CDCR;
  wire signed [63:0] wCMOD   = q1p::CMOD;
  wire signed [63:0] wCMODR  = q1p::CMODR;
  wire signed [63:0] wCSC    = q1p::CSC;
  wire signed [63:0] wCSCR   = q1p::CSCR;
  wire signed [63:0] wCSCF   = q1p::CSCF;
  wire signed [63:0] wCNEG   = q1p::CNEG;
  wire signed [63:0] wCNEGF  = q1p::CNEGF;
  wire signed [63:0] wCAC    = q1p::CAC;
  wire signed [63:0] wCACR   = q1p::CACR;
  wire signed [63:0] wCAMC   = q1p::CAMC;
  wire signed [63:0] wCAMCR  = q1p::CAMCR;
  wire signed [63:0] wCAPC   = q1p::CAPC;
  wire signed [63:0] wCMCL   = q1p::CMCL;
  wire signed [63:0] wCDEEP  = q1p::CDEEP;
  wire signed [63:0] wCLT    = q1p::CLT;
  wire signed [63:0] wCPNAME = q1p::CPNAME;
  wire signed [63:0] wCPCEQ  = q1p::CPCEQ;
  wire signed [63:0] wCPLAND = q1p::CPLAND;
  wire signed [63:0] wCPNOT  = q1p::CPNOT;
  wire signed [63:0] wCPTERN = q1p::CPTERN;
  wire signed [63:0] wCPOW   = q1p::CPOW;
  wire signed [63:0] wCMUL   = q1p::CMUL;
  wire signed [63:0] wCADD   = q1p::CADD;
  // the NARROW readers — the INT road is never masked
  wire signed [31:0] wNCPC   = q1p::CPC;
  wire        [7:0]  w8CPC   = q1p::CPC;
  wire signed [31:0] wNCMC   = q1p::CMC;
  assign o = wCPC ^ wCPCR ^ wCPCF ^ wCPCF0 ^ wCPCE ^ wCPCN0 ^ wCPCC ^ wCPCG ^
             wCPCGE ^ wCPCLE ^ wCPCL ^ wCPC2L ^ wCPC8 ^ wCPCBY ^ wCPCP ^ wCPCX ^
             wCPCU ^ wCPCUR ^ wCPCT ^ wCMC ^ wCMCR ^ wCMCF ^ wCDC ^ wCDCR ^
             wCMOD ^ wCMODR ^ wCSC ^ wCSCR ^ wCSCF ^ wCNEG ^ wCNEGF ^ wCAC ^
             wCACR ^ wCAMC ^ wCAMCR ^ wCAPC ^ wCMCL ^ wCDEEP ^ wCLT ^ wCPNAME ^
             wCPCEQ ^ wCPLAND ^ wCPNOT ^ wCPTERN ^ wCPOW ^ wCMUL ^ wCADD ^
             {wNCPC, wNCPC} ^ {56'b0, w8CPC} ^ {wNCMC, wNCMC};
endmodule

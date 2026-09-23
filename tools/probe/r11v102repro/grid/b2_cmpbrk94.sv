// v11u94 break arm b2 — LAW A: the comparison family under every landed
// INT-minting operator, name/negative/unsigned/wide operands, narrow and
// signed-overflow declared types, reads at 64/32/8-bit nets and in the
// param_assign and process homes.
package b2p;
  localparam int P3 = 3;
  localparam int CEQ  = (3 == 3) ** 2;
  localparam int CNE  = (3 != 3) * 5;
  localparam int CGE  = (3 >= 4) - 1;
  localparam int CLE  = (3 <= 3) % 2;
  localparam int CGT  = 7 / (4 > 3);
  localparam int CNM  = (P3 < 4) ** 3;
  localparam int CNG  = (-1 < 0) ** 2;
  localparam int CUNS = (-1 < 32'd0) * 5;
  localparam int CPN1 = (3 < 4) ** -1;
  localparam int CPN0 = (4 < 3) ** -1;
  localparam int CSUB = (3 < 4) - (4 < 3);
  localparam int CCE  = (3 == 3) ** (3 != 4);
  localparam int CWI  = (4294967296 > 1) * 3;
  localparam int CW2  = (4294967296 == 0) * 3;
  localparam int CAPC = (3 < 4) + (3 < 4) * 2;
  localparam int CCAS = (3 === 3) ** 2;
  localparam byte CBY = (3 < 4) * 200;
  localparam logic [3:0] C4 = (3 < 4) * 20;
  localparam int CUNB = ('0 < 1) ** 2;
  localparam int CMIX = (3 < 4) * P3;
  localparam int CNEGP = -(3 < 4) * 2;
  localparam longint CBIG = (3 < 4) * 64'h7FFF_FFFF_FFFF_FFFF;
  localparam int CSGN = (3 < 4) * -2;
  localparam int CNN  = CEQ ** 2;
  localparam int CAD2 = (3 < 4) + 1;
  localparam shortint CSH = (3 < 4) * 40000;
endpackage
module b2c #(parameter int PA = b2p::CEQ, parameter int PB = b2p::CBY)
            (output logic [63:0] q);
  wire signed [63:0] cPA = PA;
  wire signed [63:0] cPB = PB;
  assign q = cPA ^ cPB;
endmodule
module b2_cmpbrk94 (input logic clk, output logic [63:0] o);
  wire [63:0] q0;
  b2c u0 (.q(q0));
  wire signed [63:0] wCEQ  = b2p::CEQ;
  wire signed [63:0] wCNE  = b2p::CNE;
  wire signed [63:0] wCGE  = b2p::CGE;
  wire signed [63:0] wCLE  = b2p::CLE;
  wire signed [63:0] wCGT  = b2p::CGT;
  wire signed [63:0] wCNM  = b2p::CNM;
  wire signed [63:0] wCNG  = b2p::CNG;
  wire signed [63:0] wCUNS = b2p::CUNS;
  wire signed [63:0] wCPN1 = b2p::CPN1;
  wire signed [63:0] wCPN0 = b2p::CPN0;
  wire signed [63:0] wCSUB = b2p::CSUB;
  wire signed [63:0] wCCE  = b2p::CCE;
  wire signed [63:0] wCWI  = b2p::CWI;
  wire signed [63:0] wCW2  = b2p::CW2;
  wire signed [63:0] wCAPC = b2p::CAPC;
  wire signed [63:0] wCCAS = b2p::CCAS;
  wire signed [63:0] wCBY  = b2p::CBY;
  wire signed [63:0] wC4   = b2p::C4;
  wire signed [63:0] wCUNB = b2p::CUNB;
  wire signed [63:0] wCMIX = b2p::CMIX;
  wire signed [63:0] wCNEGP = b2p::CNEGP;
  wire signed [63:0] wCBIG = b2p::CBIG;
  wire signed [63:0] wCSGN = b2p::CSGN;
  wire signed [63:0] wCNN  = b2p::CNN;
  wire signed [63:0] wCAD2 = b2p::CAD2;
  wire signed [63:0] wCSH  = b2p::CSH;
  wire signed [31:0] nCEQ  = b2p::CEQ;
  wire        [7:0]  n8CBY = b2p::CBY;
  wire        [7:0]  n8CW  = b2p::CWI;
  wire signed [63:0] wOP   = b2p::CEQ + 1;
  wire signed [63:0] wOPM  = b2p::CEQ * 2;
  logic [7:0] vec;
  assign vec = 8'hA5;
  wire wSEL = vec[b2p::CEQ];
  logic signed [63:0] r1, r2, aC;
  always_comb r1 = b2p::CEQ;
  always_ff @(posedge clk) r2 <= b2p::CNE;
  assign aC = b2p::CGE;
  assign o = q0 ^ wCEQ ^ wCNE ^ wCGE ^ wCLE ^ wCGT ^ wCNM ^ wCNG ^ wCUNS ^ wCPN1 ^
             wC4 ^ wCUNB ^ wCMIX ^ wCNEGP ^ wCBIG ^ wCSGN ^ wCNN ^ wCAD2 ^ wCSH ^
             {nCEQ, nCEQ} ^ {56'b0, n8CBY} ^ {56'b0, n8CW} ^ wOP ^ wOPM ^
             {63'b0, wSEL} ^ r1 ^ r2 ^ aC;
endmodule

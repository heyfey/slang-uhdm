// r11u100 arm p3 — LAW C, THE BARE UNSIZED DECIMAL WITH NO OPERATOR AT ALL.
// A bare decimal is a `vpiUIntConst` carrying the digits AS WRITTEN, and the
// ONLY producer road it takes is `CompileHelper::adjustSize`'s FIRST branch
// (`CompileHelper.cpp:4107-4118`): `mask = getMask(size); uval = val & mask;`
// then `UINT:<uval>` at `VpiSize(size)`.  slang types the literal `int` and
// truncates to 32 SIGNED bits, so past 2^31 the store's sign fires the landed
// `neg91` gate and TWO fields part at once.  Crossed: magnitude x declared
// width x declared signedness.
package p3p;
  localparam longint BLBARE = 9223372036854775807;
  localparam longint BL62   = 4611686018427387904;
  localparam longint BL33   = 8589934592;
  localparam longint BL32   = 4294967296;
  localparam longint BL31   = 2147483648;
  localparam longint BL31M1 = 2147483647;
  localparam longint BL30   = 1073741824;
  localparam longint BLMAXU = 18446744073709551615;
  localparam int     IB31   = 2147483648;
  localparam int     IB32   = 4294967296;
  localparam int     IB30   = 1073741824;
  localparam integer GB31   = 2147483648;
  localparam byte    YB200  = 200;
  localparam byte    YB100  = 100;
  localparam shortint SB40K = 40000;
  localparam logic [7:0]  U8B200 = 200;
  localparam logic [7:0]  U8B300 = 300;
  localparam logic [63:0] U64BIG = 9223372036854775807;
  localparam logic signed [63:0] S64BIG = 9223372036854775807;
  localparam logic signed [7:0]  S8B200 = 200;
  localparam bit [63:0] BT64BIG = 9223372036854775807;
  localparam PIMP = 2147483648;
  localparam [63:0] PIMPR = 9223372036854775807;
  localparam longint BPAR = (9223372036854775807);
  // the LIVE CONTROLS — a bare literal that is not an unsized decimal, or an
  // unsized decimal that already agrees
  localparam longint BHEX  = 64'h7FFF_FFFF_FFFF_FFFF;
  localparam longint BBIN  = 4'b1010;
  localparam longint BDEC  = 8'd10;
  localparam longint BOCT  = 8'o12;
  localparam longint BSMALL = 6;
  localparam int     CLIT  = 6;
  localparam int     CNEG  = -2147483648;
  localparam longint CSUB  = 9223372036854775807 - 0;
  localparam real    RB    = 1.5;
  localparam string  SB    = "ab";
  localparam longint CNAME = BLBARE;
endpackage
module p3_bare100 (output logic [63:0] o);
  wire signed [63:0] wBLBARE = p3p::BLBARE;
  wire signed [63:0] wBL62   = p3p::BL62;
  wire signed [63:0] wBL33   = p3p::BL33;
  wire signed [63:0] wBL32   = p3p::BL32;
  wire signed [63:0] wBL31   = p3p::BL31;
  wire signed [63:0] wBL31M1 = p3p::BL31M1;
  wire signed [63:0] wBL30   = p3p::BL30;
  wire signed [63:0] wBLMAXU = p3p::BLMAXU;
  wire signed [63:0] wIB31   = p3p::IB31;
  wire signed [63:0] wIB32   = p3p::IB32;
  wire signed [63:0] wIB30   = p3p::IB30;
  wire signed [63:0] wGB31   = p3p::GB31;
  wire signed [63:0] wYB200  = p3p::YB200;
  wire signed [63:0] wYB100  = p3p::YB100;
  wire signed [63:0] wSB40K  = p3p::SB40K;
  wire signed [63:0] wU8B200 = p3p::U8B200;
  wire signed [63:0] wU8B300 = p3p::U8B300;
  wire signed [63:0] wU64BIG = p3p::U64BIG;
  wire signed [63:0] wS64BIG = p3p::S64BIG;
  wire signed [63:0] wS8B200 = p3p::S8B200;
  wire signed [63:0] wBT64BIG = p3p::BT64BIG;
  wire signed [63:0] wPIMP   = p3p::PIMP;
  wire signed [63:0] wPIMPR  = p3p::PIMPR;
  wire signed [63:0] wBPAR   = p3p::BPAR;
  wire signed [63:0] wBHEX   = p3p::BHEX;
  wire signed [63:0] wBBIN   = p3p::BBIN;
  wire signed [63:0] wBDEC   = p3p::BDEC;
  wire signed [63:0] wBOCT   = p3p::BOCT;
  wire signed [63:0] wBSMALL = p3p::BSMALL;
  wire signed [63:0] wCLIT   = p3p::CLIT;
  wire signed [63:0] wCNEG   = p3p::CNEG;
  wire signed [63:0] wCSUB   = p3p::CSUB;
  wire signed [63:0] wCNAME  = p3p::CNAME;
  wire        [63:0] wUBLBARE = p3p::BLBARE;
  wire signed [31:0] wNBLBARE = p3p::BLBARE;
  assign o = wBLBARE ^ wBL62 ^ wBL33 ^ wBL32 ^ wBL31 ^ wBL31M1 ^ wBL30 ^
             wBLMAXU ^ wIB31 ^ wIB32 ^ wIB30 ^ wGB31 ^ wYB200 ^ wYB100 ^
             wSB40K ^ wU8B200 ^ wU8B300 ^ wU64BIG ^ wS64BIG ^ wS8B200 ^
             wBT64BIG ^ wPIMP ^ wPIMPR ^ wBPAR ^ wBHEX ^ wBBIN ^ wBDEC ^
             wBOCT ^ wBSMALL ^ wCLIT ^ wCNEG ^ wCSUB ^ wCNAME ^ wUBLBARE ^
             {wNBLBARE, wNBLBARE};
endmodule

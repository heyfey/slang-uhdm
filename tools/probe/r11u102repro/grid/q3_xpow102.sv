// r11u102 arm q3 — LAW C (RV100-5): an UNBASED 'x / 'z OPERAND under every
// operator, in both positions.  Surelog maps 'x/'z to paX/paZ, off the digit
// road; the pass-97 tick law declines them on the LEAF road, and golden
// leaves the operation UNFOLDED — it writes a ref_obj and no constant.
package q3p;
  localparam int     CPX    = 2 ** 'x;
  localparam int     CPXL   = 'x ** 2;
  localparam int     CPZ    = 2 ** 'z;
  localparam int     CPZL   = 'z ** 2;
  localparam longint CPX64  = 2 ** 'x;
  localparam logic [7:0] CPX8 = 2 ** 'x;
  localparam int     CMX    = 2 * 'x;
  localparam int     CDX    = 4 / 'x;
  localparam int     CDXL   = 'x / 4;
  localparam int     CMODX  = 4 % 'x;
  localparam int     CSX    = 4 - 'x;
  localparam int     CSZ    = 'z - 4;
  localparam int     CAX    = 'x + 1;
  localparam int     CAXR   = 1 + 'z;
  localparam int     CNEGX  = -'x;
  localparam int     CANDX  = 'x & 1;
  localparam int     CORX   = 1 | 'z;
  localparam int     CSHLX  = 'x << 1;
  localparam int     CSHRX  = 4 >> 'x;
  localparam int     CXORX  = 'x ^ 1;
  localparam int     CLTX   = 'x < 1;
  localparam int     CEQX   = 1 == 'z;
  localparam int     CLANDX = 'x && 1;
  localparam int     CNESTX = (2 ** 'x) + 1;
  localparam int     CDEEPX = (2 * 'x) * 3;
  localparam int     CPXN   = CPX + 1;
  localparam int     CTERNX = 1 ? 2 : 'x;
  localparam int     CBX    = 2 ** 1'bx;
  localparam int     CBXH   = 4'hx + 1;
  localparam int     CUXB   = 'x;
  localparam int     CUZB   = 'z;
  // controls
  localparam int     CPOW   = 2 ** 3;
  localparam int     C1S    = '1 - 0;
  localparam int     C1P    = 2 ** '1;
  localparam int     C0P    = 2 ** '0;
endpackage
module q3_xpow102 (output logic [63:0] o);
  wire signed [63:0] wCPX    = q3p::CPX;
  wire signed [63:0] wCPXL   = q3p::CPXL;
  wire signed [63:0] wCPZ    = q3p::CPZ;
  wire signed [63:0] wCPZL   = q3p::CPZL;
  wire signed [63:0] wCPX64  = q3p::CPX64;
  wire signed [63:0] wCPX8   = q3p::CPX8;
  wire signed [63:0] wCMX    = q3p::CMX;
  wire signed [63:0] wCDX    = q3p::CDX;
  wire signed [63:0] wCDXL   = q3p::CDXL;
  wire signed [63:0] wCMODX  = q3p::CMODX;
  wire signed [63:0] wCSX    = q3p::CSX;
  wire signed [63:0] wCSZ    = q3p::CSZ;
  wire signed [63:0] wCAX    = q3p::CAX;
  wire signed [63:0] wCAXR   = q3p::CAXR;
  wire signed [63:0] wCNEGX  = q3p::CNEGX;
  wire signed [63:0] wCANDX  = q3p::CANDX;
  wire signed [63:0] wCORX   = q3p::CORX;
  wire signed [63:0] wCSHLX  = q3p::CSHLX;
  wire signed [63:0] wCSHRX  = q3p::CSHRX;
  wire signed [63:0] wCXORX  = q3p::CXORX;
  wire signed [63:0] wCLTX   = q3p::CLTX;
  wire signed [63:0] wCEQX   = q3p::CEQX;
  wire signed [63:0] wCLANDX = q3p::CLANDX;
  wire signed [63:0] wCNESTX = q3p::CNESTX;
  wire signed [63:0] wCDEEPX = q3p::CDEEPX;
  wire signed [63:0] wCPXN   = q3p::CPXN;
  wire signed [63:0] wCTERNX = q3p::CTERNX;
  wire signed [63:0] wCBX    = q3p::CBX;
  wire signed [63:0] wCBXH   = q3p::CBXH;
  wire signed [63:0] wCUXB   = q3p::CUXB;
  wire signed [63:0] wCUZB   = q3p::CUZB;
  wire signed [63:0] wCPOW   = q3p::CPOW;
  wire signed [63:0] wC1S    = q3p::C1S;
  wire signed [63:0] wC1P    = q3p::C1P;
  wire signed [63:0] wC0P    = q3p::C0P;
  wire signed [31:0] wNCPX   = q3p::CPX;
  assign o = wCPX ^ wCPXL ^ wCPZ ^ wCPZL ^ wCPX64 ^ wCPX8 ^ wCMX ^ wCDX ^
             wCDXL ^ wCMODX ^ wCSX ^ wCSZ ^ wCAX ^ wCAXR ^ wCNEGX ^ wCANDX ^
             wCORX ^ wCSHLX ^ wCSHRX ^ wCXORX ^ wCLTX ^ wCEQX ^ wCLANDX ^
             wCNESTX ^ wCDEEPX ^ wCPXN ^ wCTERNX ^ wCBX ^ wCBXH ^ wCUXB ^
             wCUZB ^ wCPOW ^ wC1S ^ wC1P ^ wC0P ^ {wNCPX, wNCPX};
endmodule

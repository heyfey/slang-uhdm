// v11u94 attack arm a4 -- file-scope params, strength/delay drive fields, struct/enum nets, wide values
localparam longint FBLB = 9223372036854775807;
localparam int FCLIT = 300;
package a4p;
  localparam longint BLB  = 9223372036854775807;
  localparam longint BADD = 4294967296 + 1;
  localparam int     CLIT = 300;
  localparam logic [79:0] W80 = 80'h1_0000_0000_0000_0005;
  localparam logic [127:0] W128U = 5;
  localparam logic [79:0] SHW = 1 << 70;
  localparam logic [63:0] H64 = 64'h8000_0000_0000_0001;
  localparam logic [63:0] O64 = 64'o1777777777777777777777;
  localparam logic [7:0] XB = 8'b1010_x010;
  localparam int CUX = 'x;
  localparam logic [7:0] ONES = '1;
  localparam logic [7:0] ZERO = '0;
  localparam bit [15:0] B1S = 1'b1;
  localparam int ISB = 4'sb1010;
  localparam logic [7:0] LSB = 4'sb1010;
endpackage
module a4_misc94 (output logic [15:0] o);
  wire [7:0] fBLB8 = FBLB;
  wire [7:0] fCLIT8 = FCLIT;
  wire (strong0, weak1) [7:0] sBLB8 = a4p::BLB;
  wire (pull0, pull1) [3:0] sCLIT4 = a4p::CLIT;
  wire [7:0] #2 dBADD8 = a4p::BADD;
  wire [7:0] #(1,2) dCLIT8 = a4p::CLIT;
  wire [7:0] vW80 = a4p::W80;
  wire [7:0] vW128U = a4p::W128U;
  wire [7:0] vSHW = a4p::SHW;
  wire [7:0] vH64 = a4p::H64;
  wire [127:0] vH64w = a4p::H64;
  wire [7:0] vO64 = a4p::O64;
  wire [3:0] vXB = a4p::XB;
  wire [3:0] vCUX = a4p::CUX;
  wire [3:0] vONES = a4p::ONES;
  wire [15:0] vONES16 = a4p::ONES;
  wire [3:0] vZERO = a4p::ZERO;
  wire [3:0] vB1S = a4p::B1S;
  wire [3:0] vISB = a4p::ISB;
  wire [15:0] vISB16 = a4p::ISB;
  wire [3:0] vLSB = a4p::LSB;
  wire [15:0] vLSB16 = a4p::LSB;
  wire signed [15:0] vsLSB16 = a4p::LSB;
  assign o = fBLB8 ^ fCLIT8 ^ sBLB8 ^ sCLIT4 ^ dBADD8 ^ dCLIT8 ^ vW80 ^ vW128U ^ vSHW ^ vH64 ^ vH64w[15:0] ^ vO64 ^ vXB ^ vCUX ^
    vONES ^ vONES16 ^ vZERO ^ vB1S ^ vISB ^ vISB16 ^ vLSB ^ vLSB16 ^ vsLSB16;
endmodule

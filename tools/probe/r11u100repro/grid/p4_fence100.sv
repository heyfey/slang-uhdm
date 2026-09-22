// r11u100 arm p4 — THE FENCES AND THE READING HOMES.  The narrow READER, the
// name chain, a const-function call on the add arm, the explicit cast, the
// `param_assign` reading home, and the shapes the three laws must DECLINE.
package p4p;
  function automatic int unsigned fu(int unsigned a); return a + 1; endfunction
  function automatic int fs(int a); return a + 1; endfunction
  localparam longint BLB   = 9223372036854775807;
  localparam longint BADD  = 4294967296 + 1;
  localparam int     CPW   = 2 ** 3;
  localparam int     CN32  = BLB;
  localparam longint CN64  = BLB;
  localparam byte    CN8   = BLB;
  localparam longint CNADD = BADD;
  localparam int     FADDS = fs(4) + 1;
  localparam int     FADDU = fu(4) + 1;
  localparam int     FBARE = fs(4);
  localparam int     CASTA = int'(4294967296 + 1);
  localparam longint CASTB = longint'(4294967296 + 1);
  localparam int     CPWC  = int'(2 ** 3);
  localparam longint BNEGA = -4294967296 + 0;
  localparam longint BSUBA = 0 - 4294967296;
  localparam longint BADDN = 4294967296 + (-1);
  localparam longint BANDN = (0 - 1) & 4294967296;
  localparam longint BSHLN = 4294967296 << (0 - 1);
  localparam longint BDEEP = ((4294967296 + 1) + 1) + 1;
  localparam longint BMIX  = (4294967296 & 4294967296) | 1;
  localparam longint BSHIFTC = 4294967296 >> 64;
endpackage
module p4sub #(parameter int P_CPW = p4p::CPW,
               parameter longint P_BLB = p4p::BLB,
               parameter longint P_BADD = p4p::BADD)
              (output logic [63:0] q);
  localparam int L_CPW = p4p::CPW;
  localparam longint L_BLB = p4p::BLB;
  assign q = P_CPW + P_BLB + P_BADD + L_CPW + L_BLB;
endmodule
module p4_fence100 (output logic [63:0] o);
  wire signed [63:0] wBLB   = p4p::BLB;
  wire signed [63:0] wBADD  = p4p::BADD;
  wire signed [63:0] wCPW   = p4p::CPW;
  wire signed [63:0] wCN32  = p4p::CN32;
  wire signed [63:0] wCN64  = p4p::CN64;
  wire signed [63:0] wCN8   = p4p::CN8;
  wire signed [63:0] wCNADD = p4p::CNADD;
  wire signed [63:0] wFADDS = p4p::FADDS;
  wire signed [63:0] wFADDU = p4p::FADDU;
  wire signed [63:0] wFBARE = p4p::FBARE;
  wire signed [63:0] wCASTA = p4p::CASTA;
  wire signed [63:0] wCASTB = p4p::CASTB;
  wire signed [63:0] wCPWC  = p4p::CPWC;
  wire signed [63:0] wBNEGA = p4p::BNEGA;
  wire signed [63:0] wBSUBA = p4p::BSUBA;
  wire signed [63:0] wBADDN = p4p::BADDN;
  wire signed [63:0] wBANDN = p4p::BANDN;
  wire signed [63:0] wBSHLN = p4p::BSHLN;
  wire signed [63:0] wBDEEP = p4p::BDEEP;
  wire signed [63:0] wBMIX  = p4p::BMIX;
  wire signed [63:0] wBSHIFTC = p4p::BSHIFTC;
  // the NARROW READERS — golden re-runs adjustSize at the READ
  wire signed [31:0] wNBLB  = p4p::BLB;
  wire        [31:0] wNUBLB = p4p::BLB;
  wire        [7:0]  w8BLB  = p4p::BLB;
  wire signed [31:0] wNBADD = p4p::BADD;
  wire        [7:0]  w8BADD = p4p::BADD;
  wire signed [31:0] wNCPW  = p4p::CPW;
  wire        [7:0]  w8CPW  = p4p::CPW;
  wire logic [63:0] qq;
  p4sub u0 (.q(qq));
  assign o = wBLB ^ wBADD ^ wCPW ^ wCN32 ^ wCN64 ^ wCN8 ^ wCNADD ^ wFADDS ^
             wFADDU ^ wFBARE ^ wCASTA ^ wCASTB ^ wCPWC ^ wBNEGA ^ wBSUBA ^
             wBADDN ^ wBANDN ^ wBSHLN ^ wBDEEP ^ wBMIX ^ wBSHIFTC ^
             {wNBLB, wNUBLB} ^ {56'b0, w8BLB} ^ {wNBADD, wNBADD} ^
             {56'b0, w8BADD} ^ {wNCPW, wNCPW} ^ {56'b0, w8CPW} ^ qq;
endmodule

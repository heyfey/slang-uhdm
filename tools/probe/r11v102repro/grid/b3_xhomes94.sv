// v11u94 break arm b3 — LAW C: the decline in every home a package parameter
// is read (process statements, ranges, case items, port connections, system
// task args, function bodies, param overrides), plus operator shapes the
// implementer's grid does not carry (0 && 'x, 1 || 'x, 'x & 0, a mixed based
// x/z digit, reductions, a cast, a bare-leaf name hop, ternary).
package b3p;
  localparam int CPX  = 2 ** 'x;
  localparam int CZX  = 'x & 0;
  localparam int CLX  = 0 && 'x;
  localparam int COX  = 1 || 'x;
  localparam logic [3:0] CBX = 4'b1x00 & 4'b0011;
  localparam int CBXI = 4'b1x00 & 4'b0011;
  localparam int CX   = 'x;
  localparam int CXN  = CX + 1;
  localparam int CXB  = CPX;
  localparam int CCX  = int'('x) + 1;
  localparam int CTX  = (1 ? 2 : 'x) + 1;
  localparam int CRX  = &'x;
  localparam int CUX  = ~'x;
  localparam int CNX  = !'x;
  localparam int CSX  = $bits('x) + 1;
  localparam int CDX  = 4'dx + 1;
  localparam int CQX  = 'x * 0;
  localparam int CCMP = ('x == 'x) ** 2;
  localparam int CZZ  = 'z | 1;
  localparam int CZ1  = 1'bz + 1;
  localparam int CSM  = 8'sbx + 1;
endpackage
module b3s #(parameter int P = 5) (input logic [63:0] a, output logic [63:0] q);
  assign q = a + P;
endmodule
module b3_xhomes94 (input logic clk, output logic [63:0] o);
  import b3p::*;
  wire signed [63:0] wCZX  = b3p::CZX;
  wire signed [63:0] wCLX  = b3p::CLX;
  wire signed [63:0] wCOX  = b3p::COX;
  wire        [3:0]  wCBX  = b3p::CBX;
  wire signed [63:0] wCBXI = b3p::CBXI;
  wire signed [63:0] wCXN  = b3p::CXN;
  wire signed [63:0] wCXB  = b3p::CXB;
  wire signed [63:0] wCCX  = b3p::CCX;
  wire signed [63:0] wCTX  = b3p::CTX;
  wire signed [63:0] wCRX  = b3p::CRX;
  wire signed [63:0] wCUX  = b3p::CUX;
  wire signed [63:0] wCNX  = b3p::CNX;
  wire signed [63:0] wCSX  = b3p::CSX;
  wire signed [63:0] wCDX  = b3p::CDX;
  wire signed [63:0] wCQX  = b3p::CQX;
  wire signed [63:0] wCCMP = b3p::CCMP;
  wire signed [63:0] wCZZ  = b3p::CZZ;
  wire signed [63:0] wCZ1  = b3p::CZ1;
  wire signed [63:0] wCSM  = b3p::CSM;
  // the other homes of CPX
  logic signed [63:0] r1, r2, r3, r4, r5, r6;
  always_comb r1 = b3p::CPX;
  always_ff @(posedge clk) r2 <= b3p::CPX + 1;
  always_comb r5 = CPX;
  always_comb if (b3p::CPX == 0) r6 = 1; else r6 = 2;
  logic [b3p::CPX + 3:0] rng;
  assign rng = '0;
  logic [7:0] vec;
  assign vec = 8'hA5;
  always_comb case (vec) b3p::CPX: r3 = 1; default: r3 = 0; endcase
  function automatic int mf(); return b3p::CPX; endfunction
  always_comb r4 = mf();
  wire [63:0] sq0, sq1;
  b3s #(.P(b3p::CPX)) us0 (.a(64'd1), .q(sq0));
  b3s us1 (.a(b3p::CPX), .q(sq1));
  initial $display("%d", b3p::CPX);
  wire signed [63:0] wSEL2 = vec[b3p::CPX +: 2];
  assign o = wCZX ^ wCLX ^ wCOX ^ {60'b0, wCBX} ^ wCBXI ^ wCXN ^ wCXB ^ wCCX ^ wCTX ^
             wCRX ^ wCUX ^ wCNX ^ wCSX ^ wCDX ^ wCQX ^ wCCMP ^ wCZZ ^ wCZ1 ^ wCSM ^
             r1 ^ r2 ^ r3 ^ r4 ^ r5 ^ r6 ^ {60'b0, rng} ^ sq0 ^ sq1 ^ wSEL2;
endmodule

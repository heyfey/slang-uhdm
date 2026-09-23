// v11u94 arm b5 — the faces of the verifier's four fixes, each measured on
// real Surelog v1.87 BEFORE the fix is written: $clog2 of a negative value,
// a based literal whose x/z digit is not its leading digit, a comparison of
// two string-valued literals with an x/z, a default / empty / named argument,
// a module function over a module localparam or a package parameter, and a
// net wider than 64 bits.
package b5p;
  localparam int PNEG = -5;
  localparam int P5 = 5;
  function automatic int fs(int a); return a + 1; endfunction
  function automatic int fp(int a); return a ** 2; endfunction
  function automatic int fdef(int a, int b = 2); return a * b; endfunction
  localparam int XB1 = 4'b1x00 & 4'b0011;
  localparam int XB2 = 4'b0x00 | 4'b0001;
  localparam int XB3 = 8'h1x + 1;
  localparam int XB4 = 8'hx1 + 1;
  localparam int XB5 = 4'b1z00 + 0;
  localparam int XB6 = 6'o1x + 1;
  localparam int XB7 = 4'bx_100 & 1;
  localparam int XB8 = 2 ** 4'b1x;
  localparam int XC1 = ('x == 'x) ** 2;
  localparam int XC2 = ('x != 'z) * 3;
  localparam int XC3 = ('x < 4'b0001) + 1;
  localparam int XC4 = (4'b0001 == 'x) + 1;
  localparam int XC5 = ('x == 1) + 1;
  localparam int XC6 = (1'bx == 1'bx) * 2;
  localparam int XC7 = ('x == 4'd1) + 1;
  localparam int XC8 = ('x >= 'z) + 1;
  localparam int XC9 = ((2 ** 'x) == 'x) + 1;
endpackage
module b5m #(parameter int W = 4) (output logic [63:0] q);
  localparam int LK = 5;
  function automatic int mlk(int a); return a * LK; endfunction
  function automatic int mlks(int a); return a + LK; endfunction
  function automatic int mpk(int a); return a * b5p::P5; endfunction
  function automatic int mpks(int a); return a + b5p::P5; endfunction
  function automatic int mw(int a); return a * W; endfunction
  wire signed [63:0] mLK  = mlk(3);
  wire signed [63:0] mLKS = mlks(3);
  wire signed [63:0] mPK  = mpk(3);
  wire signed [63:0] mPKS = mpks(3);
  wire signed [63:0] mW   = mw(3);
  assign q = mLK ^ mLKS ^ mPK ^ mPKS ^ mW;
endmodule
module b5_fixfaces94 (output logic [63:0] o);
  wire [63:0] m0, m1;
  b5m u0 (.q(m0));
  b5m #(.W(9)) u1 (.q(m1));
  wire signed [63:0] wCN1 = $clog2(-5);
  wire signed [63:0] wCN2 = $clog2(2 - 7);
  wire signed [63:0] wCN3 = $clog2(b5p::PNEG);
  wire signed [63:0] wCN4 = $clog2(-1);
  wire signed [63:0] wCN5 = $clog2(b5p::PNEG + 10);
  wire signed [63:0] wD1  = b5p::fdef(3);
  wire signed [63:0] wD2  = b5p::fdef(3, 2);
  wire signed [63:0] wD3  = b5p::fdef(3, );
  wire signed [63:0] wD4  = b5p::fdef(.a(3));
  wire signed [63:0] wD5  = b5p::fdef(.a(3), .b(4));
  wire signed [63:0] wN1  = b5p::fs(.a(4));
  wire signed [63:0] wN2  = b5p::fp(.a(3));
  wire       [127:0] wW1  = b5p::fs(4);
  wire       [127:0] wW2  = $clog2(b5p::P5);
  wire       [127:0] wW3  = b5p::fp(3);
  wire        [95:0] wW4  = b5p::fp(3);
  wire signed [63:0] wXB1 = b5p::XB1;
  wire signed [63:0] wXB2 = b5p::XB2;
  wire signed [63:0] wXB3 = b5p::XB3;
  wire signed [63:0] wXB4 = b5p::XB4;
  wire signed [63:0] wXB5 = b5p::XB5;
  wire signed [63:0] wXB6 = b5p::XB6;
  wire signed [63:0] wXB7 = b5p::XB7;
  wire signed [63:0] wXB8 = b5p::XB8;
  wire signed [63:0] wXC1 = b5p::XC1;
  wire signed [63:0] wXC2 = b5p::XC2;
  wire signed [63:0] wXC3 = b5p::XC3;
  wire signed [63:0] wXC4 = b5p::XC4;
  wire signed [63:0] wXC5 = b5p::XC5;
  wire signed [63:0] wXC6 = b5p::XC6;
  wire signed [63:0] wXC7 = b5p::XC7;
  wire signed [63:0] wXC8 = b5p::XC8;
  wire signed [63:0] wXC9 = b5p::XC9;
  assign o = m0 ^ m1 ^ wCN1 ^ wCN2 ^ wCN3 ^ wCN4 ^ wCN5 ^ wD1 ^ wD2 ^ wD3 ^ wD4 ^ wD5 ^
             wN1 ^ wN2 ^ wW1[63:0] ^ wW2[63:0] ^ wW3[63:0] ^ wW4[63:0] ^ wXB1 ^ wXB2 ^
             wXB3 ^ wXB4 ^ wXB5 ^ wXB6 ^ wXB7 ^ wXB8 ^ wXC1 ^ wXC2 ^ wXC3 ^ wXC4 ^ wXC5 ^
             wXC6 ^ wXC7 ^ wXC8 ^ wXC9;
endmodule

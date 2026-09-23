// v11u94 break arm b1 — LAW B faces the implementer's grid does not carry:
// overridden formals (mint of an override), byte/negative leaves, default
// args, scalar/reg/typedef/bit returns, return-width wrap, module funcs over
// an overridden module parameter, interface and generate homes.
package b1p;
  localparam int P5 = 5;
  localparam int PM = 2 * 3;
  localparam byte PB200 = 200;
  localparam int PNEG = -5;
  function automatic int fs(int a); return a + 1; endfunction
  function automatic int fp(int a); return a ** 2; endfunction
  function automatic int fm(int a); return a * 3; endfunction
  function automatic int fadd2(int a, int b); return a + b; endfunction
  function automatic int unsigned fuadd(int unsigned a, int unsigned b); return a + b; endfunction
  function automatic int fdef(int a, int b = 2); return a * b; endfunction
  function automatic int fdefs(int a, int b = 2); return a + b; endfunction
  function automatic shortint fshs(int a); return a + 1; endfunction
  function automatic shortint fshm(int a); return a * 2; endfunction
  function automatic logic fb(int a); return a + 1; endfunction
  function automatic reg [7:0] fr8(int a); return a + 1; endfunction
  typedef logic [7:0] u8_t;
  function automatic u8_t ft8(int a); return a + 1; endfunction
  function automatic bit [7:0] fbit8(int a); return a + 1; endfunction
  function automatic logic [3:0] f4m(int a); return a * 5; endfunction
  typedef int int_t;
  function automatic int_t ftd(int a); return a + 1; endfunction
  function automatic int fsu(int unsigned a); return a + 1; endfunction
  function automatic int fnm(int a); return -a; endfunction
  function automatic longint flm(longint a); return a * a; endfunction
  function automatic int fsz(int a); return a + 32'd1; endfunction
  function automatic int fhex(int a); return a + 'h10; endfunction
  function automatic integer fis(integer a); return a + 1; endfunction
  function automatic int fps(int a); return a + P5; endfunction
  function automatic int fpm(int a); return a + PM; endfunction
endpackage
module b1c #(parameter int N = 8) (output logic [63:0] q);
  wire signed [63:0] cFS = b1p::fs(N);
  wire signed [63:0] cFP = b1p::fp(N);
  wire signed [63:0] cCL = $clog2(N);
  wire signed [63:0] cFM = b1p::fm(N);
  assign q = cFS ^ cFP ^ cCL ^ cFM;
endmodule
module b1m #(parameter int W = 4) (output logic [63:0] q);
  function automatic int mw(int a); return a * W; endfunction
  function automatic int mws(int a); return a + W; endfunction
  wire signed [63:0] mW  = mw(3);
  wire signed [63:0] mWS = mws(3);
  assign q = mW ^ mWS;
endmodule
interface b1i;
  wire [63:0] iFP = b1p::fp(3);
  wire [63:0] iFS = b1p::fs(4);
  wire [63:0] iCL = $clog2(b1p::P5);
endinterface
module b1_callbrk94 (output logic [63:0] o);
  wire [63:0] q0, q1, q2, q3, q5, m0, m1;
  b1c u0 (.q(q0));
  b1c #(.N(2 * 3)) u1 (.q(q1));
  b1c #(.N(-3)) u2 (.q(q2));
  b1c #(.N(b1p::PM)) u3 (.q(q3));
  b1c #(.N(8'hFF)) u5 (.q(q5));
  b1m u6 (.q(m0));
  b1m #(.W(7)) u7 (.q(m1));
  b1i ifc ();
  wire signed [63:0] wFSP5  = b1p::fs(b1p::P5);
  wire signed [63:0] wFSPM  = b1p::fs(b1p::PM);
  wire signed [63:0] wFSB   = b1p::fs(b1p::PB200);
  wire signed [63:0] wFPB   = b1p::fp(b1p::PB200);
  wire signed [63:0] wFMB   = b1p::fm(b1p::PB200);
  wire signed [63:0] wFSN   = b1p::fs(b1p::PNEG);
  wire signed [63:0] wFMN   = b1p::fm(b1p::PNEG);
  wire signed [63:0] wFSM3  = b1p::fs(-3);
  wire signed [63:0] wFPM3  = b1p::fp(-3);
  wire signed [63:0] wFA2O  = b1p::fadd2(2147483647, 2147483647);
  wire signed [63:0] wFUA   = b1p::fuadd(4294967295, 2);
  wire signed [63:0] wFDEF  = b1p::fdef(3);
  wire signed [63:0] wFDEFS = b1p::fdefs(3);
  wire signed [63:0] wFSHS  = b1p::fshs(70000);
  wire signed [63:0] wFSHM  = b1p::fshm(40000);
  wire signed [63:0] wFB4   = b1p::fb(4);
  wire signed [63:0] wFB5   = b1p::fb(5);
  wire signed [63:0] wFR8   = b1p::fr8(300);
  wire signed [63:0] wFT8   = b1p::ft8(300);
  wire signed [63:0] wFBIT  = b1p::fbit8(300);
  wire signed [63:0] wF4M   = b1p::f4m(7);
  wire signed [63:0] wFTD   = b1p::ftd(4);
  wire signed [63:0] wFSU   = b1p::fsu(4);
  wire signed [63:0] wFNM   = b1p::fnm(4);
  wire signed [63:0] wFLM   = b1p::flm(3000000000);
  wire signed [63:0] wFSZ   = b1p::fsz(4);
  wire signed [63:0] wFHEX  = b1p::fhex(4);
  wire signed [63:0] wFIS   = b1p::fis(4);
  wire signed [63:0] wFPS   = b1p::fps(4);
  wire signed [63:0] wFPMM  = b1p::fpm(4);
  wire signed [63:0] wFMH   = b1p::fm(8'hFF);
  wire signed [63:0] wFMSB  = b1p::fm(8'sb11111111);
  wire signed [63:0] wFMTK  = b1p::fm('1);
  wire signed [63:0] wFSTK  = b1p::fs('1);
  wire signed [63:0] wCLB   = $clog2(b1p::PB200);
  wire signed [63:0] wCLN   = $clog2(b1p::PNEG);
  wire signed [63:0] wCLM   = $clog2(b1p::PM);
  wire signed [63:0] wCLTK  = $clog2('1);
  wire signed [63:0] wCLBG  = $clog2(4294967296);
  wire signed [63:0] wCLF   = $clog2(b1p::fp(3));
  wire signed [63:0] wFFP   = b1p::fp(b1p::fp(2));
  wire signed [63:0] wFSC   = b1p::fs($clog2(16));
  wire        [0:0]  w1FS   = b1p::fs(4);
  wire        [0:0]  w1FP   = b1p::fp(3);
  wire       [127:0] wWIDE  = b1p::fp(3);
  wire        [7:0]  w8FUA  = b1p::fuadd(4294967295, 2);
  wire        [15:0] w16FSH = b1p::fshm(40000);
  generate if (1) begin : g
    wire [63:0] gFP = b1p::fp(3);
    wire [63:0] gCL = $clog2(b1p::P5);
  end endgenerate
  assign o = q0 ^ q1 ^ q2 ^ q3 ^ q5 ^ m0 ^ m1 ^ wFSP5 ^ wFSPM ^ wFSB ^ wFPB ^ wFMB ^
             wFSN ^ wFMN ^ wFSM3 ^ wFPM3 ^ wFA2O ^ wFUA ^ wFDEF ^ wFDEFS ^ wFSHS ^
             wFSHM ^ wFB4 ^ wFB5 ^ wFR8 ^ wFT8 ^ wFBIT ^ wF4M ^ wFTD ^ wFSU ^ wFNM ^
             wFLM ^ wFSZ ^ wFHEX ^ wFIS ^ wFPS ^ wFPMM ^ wFMH ^ wFMSB ^ wFMTK ^ wFSTK ^
             wCLB ^ wCLN ^ wCLM ^ wCLTK ^ wCLBG ^ wCLF ^ wFFP ^ wFSC ^ {63'b0, w1FS} ^
             {63'b0, w1FP} ^ wWIDE[63:0] ^ {56'b0, w8FUA} ^ {48'b0, w16FSH} ^
             g.gFP ^ g.gCL ^ ifc.iFP ^ ifc.iFS ^ ifc.iCL;
endmodule

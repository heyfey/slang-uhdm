// r11u102 arm q2 — LAW B (RV100-4): a CONSTANT-FUNCTION CALL and a $clog2
// read as the WHOLE right-hand side of a net declaration.  Surelog's netlist
// elaboration compiles that RHS with Reduce::Yes: a user call goes through
// CompileHelper::EvalFunc -> ExprEval::evalFunc and a $clog2 through
// compileClog2, and both hand back a constant with NO source range.
package q2p;
  localparam int P512 = 512;
  localparam int P5   = 5;
  localparam int P0   = 0;
  localparam int P1   = 1;
  localparam longint PL40 = 64'd1099511627776;
  localparam longint PL33 = 64'd8589934593;
  function automatic int fp(int a); return a ** 2; endfunction
  function automatic int fs(int a); return a + 1; endfunction
  function automatic int fm(int a); return a * 3; endfunction
  function automatic int fd(int a); return a / 2; endfunction
  function automatic int fmo(int a); return a % 3; endfunction
  function automatic int fsub(int a, int b); return a - b; endfunction
  function automatic int fadd2(int a, int b); return a + b; endfunction
  function automatic int unsigned fu(int unsigned a); return a + 1; endfunction
  function automatic logic [7:0] f8(int a); return a + 1; endfunction
  function automatic logic [7:0] f8m(int a); return a * 3; endfunction
  function automatic logic [7:0] f8o(int a); return a * 100; endfunction
  function automatic longint fl(longint a); return a - 1; endfunction
  function automatic shortint fsh(int a); return a * 2; endfunction
  function automatic byte fby(int a); return a * 2; endfunction
  function automatic integer fig(int a); return a * 2; endfunction
  function automatic int fbig(int a); return a ** 10; endfunction
  function automatic int fneg(int a); return a - 10; endfunction
  function int fst(int a); return a * 2; endfunction
  function automatic int fz(); return 7; endfunction
  function automatic int fid(int a); return a; endfunction
  function automatic int fpp(int a); return (a + 1) * 2; endfunction
  function automatic int fpar(int a); return a * P5; endfunction
  function automatic int floc(int a); int t; t = a * 2; return t; endfunction
  function automatic int fasg(int a); fasg = a * 2; endfunction
  function automatic int fif(int a); if (a > 2) return a * 2; else return a; endfunction
  function automatic int fcl(int a); return $clog2(a); endfunction
  function automatic int fcmp(int a); return (a > 2) * 5; endfunction
endpackage
module q2_callfold102 #(parameter int MP = 512) (output logic [63:0] o);
  import q2p::*;
  function automatic int mf(int a); return a ** 2; endfunction
  localparam int ML = 64;
  // HOME 1 — the net-decl-assign RHS, the user call written in place
  wire signed [63:0] wFP   = q2p::fp(3);
  wire signed [63:0] wFPI  = fp(3);
  wire signed [63:0] wFPN  = q2p::fp(q2p::P5);
  wire signed [63:0] wFPE  = q2p::fp(2 + 1);
  wire signed [63:0] wFPM  = q2p::fp(MP);
  wire signed [63:0] wFS   = q2p::fs(4);
  wire signed [63:0] wFM   = q2p::fm(4);
  wire signed [63:0] wFD   = q2p::fd(9);
  wire signed [63:0] wFMO  = q2p::fmo(8);
  wire signed [63:0] wFSUB = q2p::fsub(9, 4);
  wire signed [63:0] wFA2  = q2p::fadd2(9, 4);
  wire signed [63:0] wFU   = q2p::fu(4);
  wire signed [63:0] wF8   = q2p::f8(4);
  wire signed [63:0] wF8M  = q2p::f8m(4);
  wire signed [63:0] wF8O  = q2p::f8o(4);
  wire signed [63:0] wFL   = q2p::fl(q2p::PL40);
  wire signed [63:0] wFSH  = q2p::fsh(4);
  wire signed [63:0] wFBY  = q2p::fby(100);
  wire signed [63:0] wFIG  = q2p::fig(4);
  wire signed [63:0] wFBIG = q2p::fbig(10);
  wire signed [63:0] wFNEG = q2p::fneg(3);
  wire signed [63:0] wFST  = q2p::fst(4);
  wire signed [63:0] wFZ   = q2p::fz();
  wire signed [63:0] wFID  = q2p::fid(4);
  wire signed [63:0] wFPP  = q2p::fpp(4);
  wire signed [63:0] wFPAR = q2p::fpar(4);
  wire signed [63:0] wFLOC = q2p::floc(4);
  wire signed [63:0] wFASG = q2p::fasg(4);
  wire signed [63:0] wFIF  = q2p::fif(4);
  wire signed [63:0] wFCL  = q2p::fcl(512);
  wire signed [63:0] wFCMP = q2p::fcmp(4);
  wire signed [63:0] wMF   = mf(3);
  wire signed [63:0] wFPA  = q2p::fp(3) + 1;
  wire signed [63:0] wFPC  = int'(q2p::fp(3));
  // HOME 1 — the $clog2 written in place, argument shapes
  wire signed [63:0] wCL   = $clog2(q2p::P512);
  wire signed [63:0] wCLI  = $clog2(P512);
  wire signed [63:0] wCLL  = $clog2(512);
  wire signed [63:0] wCLX  = $clog2(q2p::P512 + 1);
  wire signed [63:0] wCLM  = $clog2(MP);
  wire signed [63:0] wCLML = $clog2(ML);
  wire signed [63:0] wCL0  = $clog2(q2p::P0);
  wire signed [63:0] wCL1  = $clog2(q2p::P1);
  wire signed [63:0] wCLB  = $clog2(q2p::PL33);
  wire signed [63:0] wCLH  = $clog2(32'h100);
  wire signed [63:0] wCLA  = $clog2(q2p::P512) + 1;
  wire signed [63:0] wBITS = $bits(q2p::P512);
  wire signed [63:0] wSIGN = $signed(q2p::P512);
  // narrow readers
  wire signed [31:0] wNFP  = q2p::fp(3);
  wire        [7:0]  w8CL  = $clog2(q2p::P512);
  wire        [2:0]  w3CL  = $clog2(q2p::P512);
  wire        [3:0]  w4FS  = q2p::fs(20);
  wire        [3:0]  w4FM  = q2p::fm(20);
  wire               w1FZ  = q2p::fz();
  assign o = wFP ^ wFPI ^ wFPN ^ wFPE ^ wFPM ^ wFS ^ wFM ^ wFD ^ wFMO ^ wFSUB ^
             wFA2 ^ wFU ^ wF8 ^ wF8M ^ wF8O ^ wFL ^ wFSH ^ wFBY ^ wFIG ^ wFBIG ^
             wFNEG ^ wFST ^ wFZ ^ wFID ^ wFPP ^ wFPAR ^ wFLOC ^ wFASG ^ wFIF ^
             wFCL ^ wFCMP ^ wMF ^ wFPA ^ wFPC ^ wCL ^ wCLI ^ wCLL ^ wCLX ^ wCLM ^
             wCLML ^ wCL0 ^ wCL1 ^ wCLB ^ wCLH ^ wCLA ^ wBITS ^ wSIGN ^
             {wNFP, wNFP} ^ {56'b0, w8CL} ^ {61'b0, w3CL} ^ {60'b0, w4FS} ^
             {60'b0, w4FM} ^ {63'b0, w1FZ};
endmodule

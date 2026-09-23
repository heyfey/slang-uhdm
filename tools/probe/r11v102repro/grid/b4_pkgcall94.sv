// v11u94 break arm b4 — § pkgCallMintIsTheReturnMint102: package parameters
// initialized by a user call, every mint x declared width x reader width,
// plus homes (param_assign, process, operation operand).
package b4p;
  localparam int P5 = 5;
  localparam int PM = 2 * 3;
  function automatic int fs(int a); return a + 1; endfunction
  function automatic int fp(int a); return a ** 2; endfunction
  function automatic int fm(int a); return a * 3; endfunction
  function automatic shortint fshm(int a); return a * 2; endfunction
  function automatic logic [7:0] f8(int a); return a + 1; endfunction
  function automatic int unsigned fuadd(int unsigned a, int unsigned b); return a + b; endfunction
  function automatic int fz(); return 7; endfunction
  function automatic int fid(int a); return a; endfunction
  function automatic int fneg(int a); return a - 10; endfunction
  function automatic int fdef(int a, int b = 2); return a * b; endfunction
  localparam int QFS  = fs(4);
  localparam int QFP  = fp(3);
  localparam shortint QSH = fshm(40000);
  localparam int QF8  = f8(300);
  localparam logic [3:0] Q4FS = fs(20);
  localparam logic [3:0] Q4FP = fp(5);
  localparam longint QFPB = fp(100000);
  localparam int QFSP = fs(QFP);
  localparam int QFSN = fs(P5);
  localparam int QFSM = fs(PM);
  localparam int QFPM = fp(-3);
  localparam longint QUA = fuadd(4294967295, 2);
  localparam int QFZ  = fz();
  localparam int QFID = fid(4);
  localparam int QNEG = fneg(3);
  localparam int QNG2 = fneg(30);
  localparam int QDEF = fdef(3);
  localparam byte QBY = fs(100);
  localparam int unsigned QU = fs(4);
  localparam QIMP = fs(4);
  localparam logic [63:0] QL64 = fs(4);
endpackage
module b4c #(parameter int PA = b4p::QFS) (output logic [63:0] q);
  wire signed [63:0] cPA = PA;
  assign q = cPA;
endmodule
module b4_pkgcall94 (input logic clk, output logic [63:0] o);
  wire [63:0] q0;
  b4c u0 (.q(q0));
  wire signed [63:0] wQFS  = b4p::QFS;
  wire signed [63:0] wQFP  = b4p::QFP;
  wire signed [63:0] wQSH  = b4p::QSH;
  wire signed [63:0] wQF8  = b4p::QF8;
  wire signed [63:0] wQ4FS = b4p::Q4FS;
  wire signed [63:0] wQ4FP = b4p::Q4FP;
  wire signed [63:0] wQFPB = b4p::QFPB;
  wire signed [63:0] wQFSP = b4p::QFSP;
  wire signed [63:0] wQFSN = b4p::QFSN;
  wire signed [63:0] wQFSM = b4p::QFSM;
  wire signed [63:0] wQFPM = b4p::QFPM;
  wire signed [63:0] wQUA  = b4p::QUA;
  wire signed [63:0] wQFZ  = b4p::QFZ;
  wire signed [63:0] wQFID = b4p::QFID;
  wire signed [63:0] wQNEG = b4p::QNEG;
  wire signed [63:0] wQNG2 = b4p::QNG2;
  wire signed [63:0] wQDEF = b4p::QDEF;
  wire signed [63:0] wQBY  = b4p::QBY;
  wire signed [63:0] wQU   = b4p::QU;
  wire signed [63:0] wQIMP = b4p::QIMP;
  wire signed [63:0] wQL64 = b4p::QL64;
  wire signed [31:0] nQFS  = b4p::QFS;
  wire        [7:0]  n8QFP = b4p::QFP;
  wire        [7:0]  n8QFS = b4p::QFS;
  wire signed [63:0] wOPS  = b4p::QFS + 1;
  wire signed [63:0] wOPP  = b4p::QFP * 2;
  logic signed [63:0] r1, aQ;
  always_comb r1 = b4p::QFS;
  assign aQ = b4p::QFP;
  assign o = q0 ^ wQFS ^ wQFP ^ wQSH ^ wQF8 ^ wQ4FS ^ wQ4FP ^ wQFPB ^ wQFSP ^ wQFSN ^
             wQFSM ^ wQFPM ^ wQUA ^ wQFZ ^ wQFID ^ wQNEG ^ wQNG2 ^ wQDEF ^ wQBY ^
             wQU ^ wQIMP ^ wQL64 ^ {nQFS, nQFS} ^ {56'b0, n8QFP} ^ {56'b0, n8QFS} ^
             wOPS ^ wOPP ^ r1 ^ aQ;
endmodule

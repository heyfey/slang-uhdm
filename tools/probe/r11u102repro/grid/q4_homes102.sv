// r11u102 arm q4 — THE HOMES.  The three laws' cells read in a CHILD instance
// (twice, one override), through a module parameter default, inside an
// operation, as a select index, and through a continuous assign.
package q4p;
  function automatic int fp(int a); return a ** 2; endfunction
  function automatic int fs(int a); return a + 1; endfunction
  localparam int P512 = 512;
  localparam int CPC  = (3 < 4) ** 3;
  localparam int CMC  = (3 < 4) * 3;
  localparam int CPX  = 2 ** 'x;
  localparam int CMX  = 'x * 2;
  localparam int PFS  = fs(4);
  localparam int PFP  = fp(3);
endpackage
module q4c #(parameter int N = 8,
             parameter int P_CPC = q4p::CPC,
             parameter int P_CPX = q4p::CPX,
             parameter int P_CL  = $clog2(q4p::P512),
             parameter int P_FP  = q4p::fp(3),
             parameter int P_PFS = q4p::PFS,
             parameter int P_PFP = q4p::PFP,
             parameter int P_CMX = q4p::CMX)
            (output logic [63:0] q);
  wire signed [63:0] cFP  = q4p::fp(N);
  wire signed [63:0] cFS  = q4p::fs(N);
  wire signed [63:0] cCL  = $clog2(N);
  wire signed [63:0] cCLP = $clog2(q4p::P512);
  wire signed [63:0] cCPC = q4p::CPC;
  wire signed [63:0] cCPX = q4p::CPX;
  assign q = cFP ^ cFS ^ cCL ^ cCLP ^ cCPC ^ cCPX ^ P_CPC ^ P_CPX ^ P_CL ^ P_FP ^ P_PFS ^ P_PFP ^ P_CMX;
endmodule
module q4_homes102 (output logic [63:0] o);
  import q4p::*;
  wire [63:0] q0, q1;
  q4c u0 (.q(q0));
  q4c #(.N(33)) u1 (.q(q1));
  wire signed [63:0] wOPC  = q4p::CPC + 1;
  wire signed [63:0] wOPX  = q4p::CPX + 1;
  wire signed [63:0] wCPXI = CPX;
  wire signed [63:0] wCMXI = CMX;
  wire signed [63:0] wCPCI = CPC;
  wire signed [63:0] wPFS  = q4p::PFS;
  wire signed [63:0] wPFP  = q4p::PFP;
  logic [7:0] vec;
  assign vec = 8'hA5;
  wire wSELC = vec[q4p::CPC];
  wire wSELX = vec[q4p::CPX];
  logic signed [63:0] aCPC, aCPX, aFP, aFS, aCL;
  assign aCPC = q4p::CPC;
  assign aCPX = q4p::CPX;
  assign aFP  = q4p::fp(3);
  assign aFS  = q4p::fs(4);
  assign aCL  = $clog2(q4p::P512);
  assign o = q0 ^ q1 ^ wOPC ^ wOPX ^ wCPXI ^ wCMXI ^ wCPCI ^ wPFS ^ wPFP ^
             {62'b0, wSELC, wSELX} ^ aCPC ^ aCPX ^ aFP ^ aFS ^ aCL;
endmodule

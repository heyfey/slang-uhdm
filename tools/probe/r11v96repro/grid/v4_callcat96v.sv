// r11v96 VERIFIER arm v4 — THE CONCATENATION THAT NEVER REACHES THE CONSTANT.
// v3 found LAW C's kind-1 gate declining on a concatenation buried inside a
// SYSTEM CALL's argument, where golden hangs the declared typespec on the
// elaborated constant all the same.  This arm isolates that shape: $bits,
// $clog2 and a user function over a concatenation and over a replication, the
// mixed case where a concatenation stands OUTSIDE the call as well, and the
// same shapes on the LANDED kind-2 (`signed` / `unsigned`) and kind-0 roads.
package v4p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  function automatic int v4f(input logic [7:0] x);
    return int'(x) + 1;
  endfunction
  localparam int      FBITS = $bits({4'd1, 4'd2});          // k1, sys call
  localparam int      FCLOG = $clog2({4'd1, 4'd2});         // k1, sys call
  localparam int      FFUNC = v4f({4'd1, 4'd2});            // k1, user call
  localparam int      FBREP = $bits({2{4'd3}});             // k1, replication
  localparam int      FMIX  = $bits({4'd1, 4'd2}) + 4;      // k1, call + add
  localparam int      FOUT  = $bits(8'd18) + {4'd0, 4'd1};  // concat OUTSIDE
  localparam signed   FSB   = $bits({4'd1, 4'd2});          // k2 signed
  localparam unsigned FUB   = $bits({4'd1, 4'd2});          // k2 unsigned
  localparam          FIMP  = $bits({4'd1, 4'd2});          // k0 implicit
  localparam int      FPLN  = $bits(8'd18);                 // the control
endpackage
module v4_callcat96v;
  localparam logic [7:0]         Q1 = v4p::FBITS;
  localparam logic signed [15:0] Q2 = v4p::FBITS;
  localparam logic [7:0]         Q3 = v4p::FCLOG;
  localparam logic signed [15:0] Q4 = v4p::FCLOG;
  localparam logic [7:0]         Q5 = v4p::FFUNC;
  localparam logic signed [15:0] Q6 = v4p::FFUNC;
  localparam logic [7:0]         Q7 = v4p::FBREP;
  localparam logic signed [15:0] Q8 = v4p::FBREP;
  localparam logic [7:0]         Q9 = v4p::FMIX;
  localparam logic signed [15:0] QA = v4p::FMIX;
  localparam logic [7:0]         QB = v4p::FOUT;
  localparam logic signed [15:0] QC = v4p::FOUT;
  localparam logic [7:0]         QD = v4p::FSB;
  localparam logic signed [15:0] QE = v4p::FSB;
  localparam logic [7:0]         QF = v4p::FUB;
  localparam logic signed [15:0] QG = v4p::FUB;
  localparam logic [7:0]         QH = v4p::FIMP;
  localparam logic signed [15:0] QI = v4p::FIMP;
  localparam logic [7:0]         QJ = v4p::FPLN;
  localparam logic signed [15:0] QK = v4p::FPLN;
  localparam v4p::t A = '{bail: 8'hxA, a: Q1, b: Q2, c: Q3, d: Q4,
                          e: Q5, f: Q6, g: Q7};
  localparam v4p::t B = '{bail: 8'hxA, a: Q8, b: Q9, c: QA, d: QB,
                          e: QC, f: QD, g: QE};
  localparam v4p::t C = '{bail: 8'hxA, a: QF, b: QG, c: QH, d: QI,
                          e: QJ, f: QK, g: Q1};
  v4_sink #(.R(A)) s1();
  v4_sink #(.R(B)) s2();
  v4_sink #(.R(C)) s3();
endmodule
module v4_sink #(parameter v4p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule

// v11u72 BREAK ARM 7 — THE RANGE-STRICT DECIMAL LEAF THE VALUE TABLE DOES NOT
// MODEL.  `get_value` reads a `DEC:`/`INT:` operand with `NumUtils::parseInt64`,
// which is RANGE-STRICT (ExprEval.cpp:1978, :2008), so a decimal leaf whose
// magnitude exceeds int64 makes the arm REFUSE — there is no size guard, only a
// parse failure.  `red72Int64` has no such face: it hands the leaf to
// `tryEval` and answers `Value` from `as<uint64_t>()`.  Does that write a
// value where golden bails, and does the missed refusal cost a probe size?
// Operand 0 is the candidate, `K+1`/`K+2` on 8-bit members are the probes.
package p7;
  localparam int         K  = 6;
  localparam bit [63:0]  DU = 64'd18446744073709551614;  // DEC leaf > int64
  localparam bit [63:0]  DS = 64'd9223372036854775807;   // DEC leaf == int64 max
  typedef struct packed {
    logic [63:0] a;   // the candidate
    logic [7:0]  p1;  // K + 1
    logic [7:0]  p2;  // K + 2
  } w_t;
  localparam w_t A = '{a: DU - 1,   p1: K+1, p2: K+2};  // beyond-int64 DEC leaf
  localparam w_t B = '{a: DU,       p1: K+1, p2: K+2};  // the leaf alone
  localparam w_t C = '{a: DS + 1,   p1: K+1, p2: K+2};  // int64 max + 1
  localparam w_t D = '{a: DS - 1,   p1: K+1, p2: K+2};  // inside int64
  localparam w_t E = '{a: DU % 3,   p1: K+1, p2: K+2};  // modulo with a beyond-int64 leaf
  localparam w_t F = '{a: K * 2,    p1: K+1, p2: K+2};  // no-bail CONTROL
endpackage
module v7_decwide72 #(parameter p7::w_t CA = p7::A, parameter p7::w_t CB = p7::B,
                      parameter p7::w_t CC = p7::C, parameter p7::w_t CD = p7::D,
                      parameter p7::w_t CE = p7::E, parameter p7::w_t CF = p7::F)
                     (output logic [63:0] a1, output logic [7:0] b1,
                      output logic [7:0] c1, output logic [63:0] a2,
                      output logic [7:0] b2, output logic [7:0] c2,
                      output logic [63:0] a3, output logic [7:0] b3,
                      output logic [7:0] c3, output logic [63:0] a4,
                      output logic [7:0] b4, output logic [7:0] c4,
                      output logic [63:0] a5, output logic [7:0] b5,
                      output logic [7:0] c5, output logic [63:0] a6,
                      output logic [7:0] b6, output logic [7:0] c6);
  assign a1 = CA.a; assign b1 = CA.p1; assign c1 = CA.p2;
  assign a2 = CB.a; assign b2 = CB.p1; assign c2 = CB.p2;
  assign a3 = CC.a; assign b3 = CC.p1; assign c3 = CC.p2;
  assign a4 = CD.a; assign b4 = CD.p1; assign c4 = CD.p2;
  assign a5 = CE.a; assign b5 = CE.p1; assign c5 = CE.p2;
  assign a6 = CF.a; assign b6 = CF.p1; assign c6 = CF.p2;
endmodule

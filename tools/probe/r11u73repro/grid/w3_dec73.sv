// r11u73 arm w3 — THE RANGE-STRICT DECIMAL LEAF (LAW C, r11v72's RV-2).
// `get_value`'s `vpiDecConst` arm (`ExprEval.cpp:1978`) has NO size guard: it
// strips `DEC:` and calls `NumUtils::parseInt64`, which is `std::from_chars`
// into an `int64_t` and therefore RANGE-STRICT.  A based-DECIMAL leaf whose
// magnitude exceeds int64 makes the whole arm refuse, while the same width in
// HEX/BIN/OCT refuses on the DECLARED width instead (`VpiSize() > 64`) and a
// `UINT:` operand is read LENIENTLY (`parseIntLenient`, signed first then
// unsigned) and does NOT refuse.
// Operand 0 is the candidate; `K+1`/`K+2` on 8-bit members are the probes
// (8 = completed, 64 = bailed).  Each member read EXACTLY ONCE.
package q3;
  localparam int         K    = 6;
  localparam bit [63:0]  DU   = 64'd18446744073709551614; // DEC leaf > int64
  localparam bit [63:0]  DS   = 64'd9223372036854775807;  // DEC leaf == int64max
  localparam bit [95:0]  D96  = 96'd5;                    // wide DEC, small value
  localparam bit [95:0]  D96W = 96'd18446744073709551616;  // wide DEC, > uint64
  localparam bit [63:0]  HU   = 64'hFFFFFFFFFFFFFFFE;     // the same bits, HEX
  typedef struct packed {
    logic [63:0] a;
    logic [7:0]  p1;
    logic [7:0]  p2;
  } w_t;
  localparam w_t A = '{a: DU - 1,        p1: K+1, p2: K+2}; // NAME leaf in an arm
  localparam w_t B = '{a: DU,            p1: K+1, p2: K+2}; // the NAME alone at op0
  localparam w_t C = '{a: 64'd18446744073709551614 - 1,
                                         p1: K+1, p2: K+2}; // LITERAL leaf in an arm
  localparam w_t D = '{a: 64'd18446744073709551614,
                                         p1: K+1, p2: K+2}; // LITERAL alone at op0
  localparam w_t E = '{a: DU % 3,        p1: K+1, p2: K+2}; // modulo, beyond-int64 leaf
  localparam w_t F = '{a: DS + 1,        p1: K+1, p2: K+2}; // int64max, arm wraps
  localparam w_t G = '{a: DS - 1,        p1: K+1, p2: K+2}; // inside int64
  localparam w_t H = '{a: D96 * 2,       p1: K+1, p2: K+2}; // wide DEC, small: completes
  localparam w_t I = '{a: HU - 1,        p1: K+1, p2: K+2}; // the SAME bits in HEX
  localparam w_t J = '{a: K * 2,         p1: K+1, p2: K+2}; // no-bail CONTROL
  localparam w_t L = '{a: D96W - 1,      p1: K+1, p2: K+2}; // wide DEC beyond uint64
  localparam w_t M = '{a: D96W,          p1: K+1, p2: K+2}; // the SAME leaf at op0
  localparam w_t N = '{a: 96'd18446744073709551616,
                                         p1: K+1, p2: K+2}; // the LITERAL at op0
endpackage
module w3_dec73 #(parameter q3::w_t CA = q3::A, parameter q3::w_t CB = q3::B,
                  parameter q3::w_t CC = q3::C, parameter q3::w_t CD = q3::D,
                  parameter q3::w_t CE = q3::E, parameter q3::w_t CF = q3::F,
                  parameter q3::w_t CG = q3::G, parameter q3::w_t CH = q3::H,
                  parameter q3::w_t CI = q3::I, parameter q3::w_t CJ = q3::J,
                  parameter q3::w_t CL = q3::L, parameter q3::w_t CM = q3::M,
                  parameter q3::w_t CN = q3::N)
                 (output logic [63:0] a1, output logic [7:0] b1,
                  output logic [7:0] c1, output logic [63:0] a2,
                  output logic [7:0] b2, output logic [7:0] c2,
                  output logic [63:0] a3, output logic [7:0] b3,
                  output logic [7:0] c3, output logic [63:0] a4,
                  output logic [7:0] b4, output logic [7:0] c4,
                  output logic [63:0] a5, output logic [7:0] b5,
                  output logic [7:0] c5, output logic [63:0] a6,
                  output logic [7:0] b6, output logic [7:0] c6,
                  output logic [63:0] a7, output logic [7:0] b7,
                  output logic [7:0] c7, output logic [63:0] a8,
                  output logic [7:0] b8, output logic [7:0] c8,
                  output logic [63:0] a9, output logic [7:0] b9,
                  output logic [7:0] c9, output logic [63:0] a10,
                  output logic [7:0] b10, output logic [7:0] c10,
                  output logic [63:0] a11, output logic [7:0] b11,
                  output logic [7:0] c11, output logic [63:0] a12,
                  output logic [7:0] b12, output logic [7:0] c12,
                  output logic [63:0] a13, output logic [7:0] b13,
                  output logic [7:0] c13);
  assign a1 = CA.a; assign b1 = CA.p1; assign c1 = CA.p2;
  assign a2 = CB.a; assign b2 = CB.p1; assign c2 = CB.p2;
  assign a3 = CC.a; assign b3 = CC.p1; assign c3 = CC.p2;
  assign a4 = CD.a; assign b4 = CD.p1; assign c4 = CD.p2;
  assign a5 = CE.a; assign b5 = CE.p1; assign c5 = CE.p2;
  assign a6 = CF.a; assign b6 = CF.p1; assign c6 = CF.p2;
  assign a7 = CG.a; assign b7 = CG.p1; assign c7 = CG.p2;
  assign a8 = CH.a; assign b8 = CH.p1; assign c8 = CH.p2;
  assign a9 = CI.a; assign b9 = CI.p1; assign c9 = CI.p2;
  assign a10 = CJ.a; assign b10 = CJ.p1; assign c10 = CJ.p2;
  assign a11 = CL.a; assign b11 = CL.p1; assign c11 = CL.p2;
  assign a12 = CM.a; assign b12 = CM.p1; assign c12 = CM.p2;
  assign a13 = CN.a; assign b13 = CN.p1; assign c13 = CN.p2;
endmodule

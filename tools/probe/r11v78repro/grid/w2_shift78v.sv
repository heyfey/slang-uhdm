// r11v78 VERIFIER arm w2 — BREAK LAW D (§ redShiftIsUnsignedSixtyFour78).
// The count boundary at 63/64/65, a NEGATIVE count, a count that is itself a
// based literal, a nested shift, the unsized operand the producer refuses, an
// UNKNOWN-digit operand, the unary-minus operand, and the >> of a value whose
// written digits overflow int64.  64-bit members so nothing is masked away.
package w2;
  localparam int K  = 6;
  localparam int unsigned KU = 6;
  typedef struct packed {
    logic [63:0] a;
    logic [7:0]  p1;
    logic [7:0]  p2;
  } w2_t;
  localparam w2_t A = '{a: 8'sd200 >>> 63,  p1: K+1, p2: K+2};
  localparam w2_t B = '{a: 8'sd200 >>> 64,  p1: K+1, p2: K+2}; // &63 -> 0
  localparam w2_t C = '{a: 8'sd200 >>> 65,  p1: K+1, p2: K+2}; // &63 -> 1
  localparam w2_t D = '{a: 8'sd200 <<  64,  p1: K+1, p2: K+2}; // &63 -> 0
  localparam w2_t E = '{a: 8'sd200 >>> (K - 7), p1: K+1, p2: K+2}; // count -1
  localparam w2_t F = '{a: 8'sd200 >>> 4'd2, p1: K+1, p2: K+2};    // based cnt
  localparam w2_t G = '{a: (8'sd200 >>> 1) >>> 1, p1: K+1, p2: K+2};
  localparam w2_t H = '{a: 8'sd200 >>> 1 + 1, p1: K+1, p2: K+2};   // precedence
  localparam w2_t I = '{a: 64'hFFFFFFFFFFFFFFFF >>> 1, p1: K+1, p2: K+2};
  localparam w2_t J = '{a: -8'sd100 >>> 1,  p1: K+1, p2: K+2};     // unary minus
  localparam w2_t L = '{a: 8'sd200 >>> 8'sd200, p1: K+1, p2: K+2}; // cnt 200&63
  localparam w2_t M = '{a: 8'hAx >>> 1,     p1: K+1, p2: K+2};     // UNKNOWN
  localparam w2_t N = '{a: 4'hF0 >>> 2,     p1: K+1, p2: K+2};
  localparam w2_t O = '{a: KU << 1,         p1: K+1, p2: K+2};     // CTL
  localparam w2_t P = '{a: K >>> 1,         p1: K+1, p2: K+2};     // CTL
endpackage
module w2_shift78v #(parameter w2::w2_t CA = w2::A, parameter w2::w2_t CB = w2::B,
                     parameter w2::w2_t CC = w2::C, parameter w2::w2_t CD = w2::D,
                     parameter w2::w2_t CE = w2::E, parameter w2::w2_t CF = w2::F,
                     parameter w2::w2_t CG = w2::G, parameter w2::w2_t CH = w2::H,
                     parameter w2::w2_t CI = w2::I, parameter w2::w2_t CJ = w2::J,
                     parameter w2::w2_t CL = w2::L, parameter w2::w2_t CM = w2::M,
                     parameter w2::w2_t CN = w2::N, parameter w2::w2_t CO = w2::O,
                     parameter w2::w2_t CP = w2::P)
                    (output logic [63:0] a1,  output logic [7:0] b1,
                     output logic [7:0]  c1,  output logic [63:0] a2,
                     output logic [7:0]  b2,  output logic [7:0] c2,
                     output logic [63:0] a3,  output logic [7:0] b3,
                     output logic [7:0]  c3,  output logic [63:0] a4,
                     output logic [7:0]  b4,  output logic [7:0] c4,
                     output logic [63:0] a5,  output logic [7:0] b5,
                     output logic [7:0]  c5,  output logic [63:0] a6,
                     output logic [7:0]  b6,  output logic [7:0] c6,
                     output logic [63:0] a7,  output logic [7:0] b7,
                     output logic [7:0]  c7,  output logic [63:0] a8,
                     output logic [7:0]  b8,  output logic [7:0] c8,
                     output logic [63:0] a9,  output logic [7:0] b9,
                     output logic [7:0]  c9,  output logic [63:0] a10,
                     output logic [7:0]  b10, output logic [7:0] c10,
                     output logic [63:0] a11, output logic [7:0] b11,
                     output logic [7:0]  c11, output logic [63:0] a12,
                     output logic [7:0]  b12, output logic [7:0] c12,
                     output logic [63:0] a13, output logic [7:0] b13,
                     output logic [7:0]  c13, output logic [63:0] a14,
                     output logic [7:0]  b14, output logic [7:0] c14,
                     output logic [63:0] a15, output logic [7:0] b15,
                     output logic [7:0]  c15);
  assign a1  = CA.a; assign b1  = CA.p1; assign c1  = CA.p2;
  assign a2  = CB.a; assign b2  = CB.p1; assign c2  = CB.p2;
  assign a3  = CC.a; assign b3  = CC.p1; assign c3  = CC.p2;
  assign a4  = CD.a; assign b4  = CD.p1; assign c4  = CD.p2;
  assign a5  = CE.a; assign b5  = CE.p1; assign c5  = CE.p2;
  assign a6  = CF.a; assign b6  = CF.p1; assign c6  = CF.p2;
  assign a7  = CG.a; assign b7  = CG.p1; assign c7  = CG.p2;
  assign a8  = CH.a; assign b8  = CH.p1; assign c8  = CH.p2;
  assign a9  = CI.a; assign b9  = CI.p1; assign c9  = CI.p2;
  assign a10 = CJ.a; assign b10 = CJ.p1; assign c10 = CJ.p2;
  assign a11 = CL.a; assign b11 = CL.p1; assign c11 = CL.p2;
  assign a12 = CM.a; assign b12 = CM.p1; assign c12 = CM.p2;
  assign a13 = CN.a; assign b13 = CN.p1; assign c13 = CN.p2;
  assign a14 = CO.a; assign b14 = CO.p1; assign c14 = CO.p2;
  assign a15 = CP.a; assign b15 = CP.p1; assign c15 = CP.p2;
endmodule

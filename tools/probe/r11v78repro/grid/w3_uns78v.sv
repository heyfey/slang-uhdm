// r11v78 VERIFIER arm w3 — BREAK LAW C (§ patOperandUnsignedArmValue78) and
// LAW E (§ caSubstLeafCtSeesParens78).  Arms whose producer encoding is NOT
// the unsigned one, arms the producer computes with get_uvalue where our
// int64 table uses get_value, the multiply/divide/mod/power arms beside the
// add, a bitwise arm the table abstains on, a based leaf reached through TWO
// name hops, and the parenthesised faces at several depths.
package w3;
  localparam int K = 6;
  localparam int unsigned KU = 6;
  localparam     PA = 4'hFF;          // an untyped name over a based leaf
  localparam     PB = PA;             // TWO hops
  typedef struct packed {
    logic [63:0] a;
    logic [7:0]  p1;
    logic [7:0]  p2;
  } w3_t;
  // --- the producer's SIGNED arms: our else-if must NOT fire -------------
  localparam w3_t A = '{a: 2'b111 - 1,   p1: K+1, p2: K+2}; // SubOp -> INT
  localparam w3_t B = '{a: 2'b111 - 8,   p1: K+1, p2: K+2}; // INT:-1
  localparam w3_t C = '{a: 8'sd200 + 1,  p1: K+1, p2: K+2}; // DecConst -> INT
  // --- other producer arms over a based leaf ----------------------------
  localparam w3_t D = '{a: 4'hFF * 2,    p1: K+1, p2: K+2};
  localparam w3_t E = '{a: 4'hFF / 2,    p1: K+1, p2: K+2};
  localparam w3_t F = '{a: 4'hFF % 4,    p1: K+1, p2: K+2};
  localparam w3_t G = '{a: 2'b111 ** 2,  p1: K+1, p2: K+2};
  localparam w3_t H = '{a: 4'hFF & 1,    p1: K+1, p2: K+2}; // table ABSTAINS
  localparam w3_t I = '{a: 4'hFF | 1,    p1: K+1, p2: K+2}; // table ABSTAINS
  // --- the 64-bit boundary of the written digits ------------------------
  localparam w3_t J = '{a: 64'hFFFFFFFFFFFFFFFF + 1, p1: K+1, p2: K+2};
  localparam w3_t L = '{a: 64'hFFFFFFFFFFFFFFFF + 2, p1: K+1, p2: K+2};
  // --- NAME hops over a based leaf --------------------------------------
  localparam w3_t M = '{a: PA + 1,       p1: K+1, p2: K+2}; // ONE hop
  localparam w3_t N = '{a: PB + 1,       p1: K+1, p2: K+2}; // TWO hops
  // --- LAW E: the parenthesised faces -----------------------------------
  localparam w3_t O = '{a: ((8'sd200)) + 1, p1: K+1, p2: K+2}; // DOUBLE paren
  localparam w3_t P = '{a: (4'hFF) + 1,  p1: K+1, p2: K+2};
  localparam w3_t Q = '{a: (K) + 1,      p1: K+1, p2: K+2};   // paren on a NAME
  localparam w3_t R = '{a: ('1) + 1,     p1: K+1, p2: K+2};   // unbased unsized
  localparam w3_t S = '{a: (8'sd200 + 1), p1: K+1, p2: K+2};  // paren the ARM
endpackage
module w3_uns78v #(parameter w3::w3_t CA = w3::A, parameter w3::w3_t CB = w3::B,
                   parameter w3::w3_t CC = w3::C, parameter w3::w3_t CD = w3::D,
                   parameter w3::w3_t CE = w3::E, parameter w3::w3_t CF = w3::F,
                   parameter w3::w3_t CG = w3::G, parameter w3::w3_t CH = w3::H,
                   parameter w3::w3_t CI = w3::I, parameter w3::w3_t CJ = w3::J,
                   parameter w3::w3_t CL = w3::L, parameter w3::w3_t CM = w3::M,
                   parameter w3::w3_t CN = w3::N, parameter w3::w3_t CO = w3::O,
                   parameter w3::w3_t CP = w3::P, parameter w3::w3_t CQ = w3::Q,
                   parameter w3::w3_t CR = w3::R, parameter w3::w3_t CS = w3::S)
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
                   output logic [7:0]  c15, output logic [63:0] a16,
                   output logic [7:0]  b16, output logic [7:0] c16,
                   output logic [63:0] a17, output logic [7:0] b17,
                   output logic [7:0]  c17, output logic [63:0] a18,
                   output logic [7:0]  b18, output logic [7:0] c18);
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
  assign a16 = CQ.a; assign b16 = CQ.p1; assign c16 = CQ.p2;
  assign a17 = CR.a; assign b17 = CR.p1; assign c17 = CR.p2;
  assign a18 = CS.a; assign b18 = CS.p1; assign c18 = CS.p2;
endmodule

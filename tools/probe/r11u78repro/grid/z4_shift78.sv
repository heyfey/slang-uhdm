// r11u78 arm z4 — THE SHIFT ARMS.  `ExprEval::reduceExpr` gives `>>` and
// `>>>` ONE body (`ExprEval.cpp:3149-3171`) and `<<`/`<<<` another
// (`:3236-3255`); BOTH are `(uint64_t)val0 >>/<< (uint64_t)val1`, both mint
// `UINT:` at `vpiSize` 64, and `val0` is `get_value` — the WRITTEN DIGITS.
// There is no sign fill in either.  So `8'sd200 >>> 1` is golden `UINT:100`
// (200 >> 1) and ours `UINT:18446744073709551588` (slang's -56 >>> 1 = -28).
// Members are 64 bits so nothing is masked away; `K+1`/`K+2` probe the member
// stamp.  The `X*` rows are the faces the producer REFUSES.
package z4;
  localparam int K  = 6;
  localparam int unsigned KU = 6;
  localparam      SD8 = 8'sd200;
  localparam      W96 = 96'h123456789ABCDEF012345678;
  typedef struct packed {
    logic [63:0] a;
    logic [7:0]  p1;
    logic [7:0]  p2;
  } z4_t;
  // --- the arithmetic right shift over a signed based decimal ------------
  localparam z4_t A = '{a: 8'sd200 >>> 1,   p1: K+1, p2: K+2}; // 100 or -28
  localparam z4_t B = '{a: 8'sd200 >> 1,    p1: K+1, p2: K+2}; // 100
  localparam z4_t C = '{a: 8'sd200 <<< 1,   p1: K+1, p2: K+2}; // 400 or -112
  localparam z4_t D = '{a: 8'sd200 << 1,    p1: K+1, p2: K+2}; // 400
  // --- the same over the other bases -------------------------------------
  localparam z4_t E = '{a: 8'shC8 >>> 2,    p1: K+1, p2: K+2}; // 50
  localparam z4_t F = '{a: 4'sb1111 >>> 1,  p1: K+1, p2: K+2}; // 7 or -1
  localparam z4_t G = '{a: 3'so7 >>> 1,     p1: K+1, p2: K+2}; // 3 or -1
  localparam z4_t H = '{a: 4'hFF >>> 2,     p1: K+1, p2: K+2}; // 63
  // --- a NAME hop and a nested arm ---------------------------------------
  localparam z4_t I = '{a: SD8 >>> 1,       p1: K+1, p2: K+2}; // 100
  localparam z4_t J = '{a: (8'sd200 >>> 1) + 1, p1: K+1, p2: K+2}; // 101
  localparam z4_t L = '{a: 8'sd200 >>> 0,   p1: K+1, p2: K+2}; // 200
  // --- the UNSIGNED controls that must NOT move --------------------------
  localparam z4_t M = '{a: KU >> 1,         p1: K+1, p2: K+2}; // CTL 3
  localparam z4_t N = '{a: K << 2,          p1: K+1, p2: K+2}; // CTL 24
  localparam z4_t O = '{a: (K - 1) << 1,    p1: K+1, p2: K+2}; // CTL 10
  localparam z4_t P = '{a: KU >>> 1,        p1: K+1, p2: K+2}; // CTL 3
  // --- the REFUSAL faces --------------------------------------------------
  localparam z4_t Q = '{a: W96 >>> 1,       p1: K+1, p2: K+2}; // >64b: refuses
  localparam z4_t R = '{a: 8'sd200 >>> 70,  p1: K+1, p2: K+2}; // count > 63
  localparam z4_t S = '{a: 8'sd200 << 70,   p1: K+1, p2: K+2}; // count > 63
  localparam z4_t T = '{a: 65'd36893488147419103232 >>> 1, p1: K+1, p2: K+2};
endpackage
module z4_shift78 #(parameter z4::z4_t CA = z4::A, parameter z4::z4_t CB = z4::B,
                    parameter z4::z4_t CC = z4::C, parameter z4::z4_t CD = z4::D,
                    parameter z4::z4_t CE = z4::E, parameter z4::z4_t CF = z4::F,
                    parameter z4::z4_t CG = z4::G, parameter z4::z4_t CH = z4::H,
                    parameter z4::z4_t CI = z4::I, parameter z4::z4_t CJ = z4::J,
                    parameter z4::z4_t CL = z4::L, parameter z4::z4_t CM = z4::M,
                    parameter z4::z4_t CN = z4::N, parameter z4::z4_t CO = z4::O,
                    parameter z4::z4_t CP = z4::P, parameter z4::z4_t CQ = z4::Q,
                    parameter z4::z4_t CR = z4::R, parameter z4::z4_t CS = z4::S,
                    parameter z4::z4_t CT = z4::T)
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
                    output logic [7:0]  b18, output logic [7:0] c18,
                    output logic [63:0] a19, output logic [7:0] b19,
                    output logic [7:0]  c19);
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
  assign a19 = CT.a; assign b19 = CT.p1; assign c19 = CT.p2;
endmodule

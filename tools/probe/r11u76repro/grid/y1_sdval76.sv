// r11u76 arm y1 — THE SIGNED BASED-DECIMAL VALUE, widths x arms x positions.
// LAW A: the producer reads `W'sd<digits>` by its WRITTEN MAGNITUDE (the
// `DEC:` string), where we read slang's stored SVInt and SIGN-EXTEND.
// Operand 0 is the candidate at a 64-bit member (the VALUE face); `K+1`/`K+2`
// on 8-bit members are the BAIL probes (8 = the walk stamped the member
// width, 64 = it bailed at operand 0).
package y1;
  localparam int K = 6;
  localparam       SD8  = 8'sd200;      // a NAME onto a signed decimal
  localparam       SD32 = 32'sd4294967295;
  localparam byte  TSD  = 8'sd7;        // a TYPED name, positive
  typedef struct packed {
    logic [63:0] a;
    logic [7:0]  p1;
    logic [7:0]  p2;
  } y1_t;
  localparam y1_t A = '{a: 8'sd200 + 1,        p1: K+1, p2: K+2}; // g 201
  localparam y1_t B = '{a: 4'sd15 - 1,         p1: K+1, p2: K+2}; // g 14
  localparam y1_t C = '{a: 1'sd1 - 1,          p1: K+1, p2: K+2}; // g 0
  localparam y1_t D = '{a: 2'sd3 + 1,          p1: K+1, p2: K+2}; // g 4
  localparam y1_t E = '{a: 16'sd40000 + 1,     p1: K+1, p2: K+2}; // g 40001
  localparam y1_t F = '{a: 32'sd4294967295 - 1,p1: K+1, p2: K+2}; // g 4294967294
  localparam y1_t G = '{a: SD8 + 1,            p1: K+1, p2: K+2}; // NAME hop
  localparam y1_t H = '{a: SD32 - 1,           p1: K+1, p2: K+2}; // NAME hop
  localparam y1_t I = '{a: -8'sd200,           p1: K+1, p2: K+2}; // unary minus
  localparam y1_t J = '{a: 8'sd200 / 8'sd2,    p1: K+1, p2: K+2}; // divide
  localparam y1_t L = '{a: 8'sd200 % 8'sd7,    p1: K+1, p2: K+2}; // mod
  localparam y1_t M = '{a: 2'sd3 ** 2,         p1: K+1, p2: K+2}; // power
  localparam y1_t N = '{a: TSD + 1,            p1: K+1, p2: K+2}; // TYPED name
  localparam y1_t O = '{a: 8'sd7 + 1,          p1: K+1, p2: K+2}; // POS control
  localparam y1_t P = '{a: 8'd200 + 1,         p1: K+1, p2: K+2}; // UNSIGNED ctl
  localparam y1_t Q = '{a: K * 2,              p1: K+1, p2: K+2}; // no-bail CTL
  localparam y1_t R = '{a: 64'sd9223372036854775807 - 1,
                                               p1: K+1, p2: K+2}; // int64max CTL
  localparam y1_t S = '{a: 8'sd200 - 8'sd200,  p1: K+1, p2: K+2}; // g 0
  localparam y1_t T = '{a: (8'sd200 + 1) * 2,  p1: K+1, p2: K+2}; // NESTED
endpackage
module y1_sdval76 #(parameter y1::y1_t CA = y1::A, parameter y1::y1_t CB = y1::B,
                    parameter y1::y1_t CC = y1::C, parameter y1::y1_t CD = y1::D,
                    parameter y1::y1_t CE = y1::E, parameter y1::y1_t CF = y1::F,
                    parameter y1::y1_t CG = y1::G, parameter y1::y1_t CH = y1::H,
                    parameter y1::y1_t CI = y1::I, parameter y1::y1_t CJ = y1::J,
                    parameter y1::y1_t CL = y1::L, parameter y1::y1_t CM = y1::M,
                    parameter y1::y1_t CN = y1::N, parameter y1::y1_t CO = y1::O,
                    parameter y1::y1_t CP = y1::P, parameter y1::y1_t CQ = y1::Q,
                    parameter y1::y1_t CR = y1::R, parameter y1::y1_t CS = y1::S,
                    parameter y1::y1_t CT = y1::T)
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

// VERIFIER arm v4 — the VALUE face's UNMEASURED corners: digits that overflow
// uint64 in b/o/h at a NARROW declared width (base law: width<=64 -> NO
// refusal; patch: the digits refuse), the lenient hex wrap, the operand on the
// RIGHT of the arm, shifts and bitwise ops, and an UNSIZED based decimal.
package v4;
  localparam int K = 6;
  typedef struct packed {
    logic [63:0] a;
    logic [7:0]  p1;
    logic [7:0]  p2;
  } v4_t;
  localparam v4_t A = '{a: 4'h1FFFFFFFFFFFFFFFFFF + 1, p1: K+1, p2: K+2};
  localparam v4_t B = '{a: 4'b1111111111111111111111111111111111111111111111111111111111111111111 + 1, p1: K+1, p2: K+2};
  localparam v4_t C = '{a: 4'o7777777777777777777777 + 1, p1: K+1, p2: K+2};
  localparam v4_t D = '{a: 4'd99999999999999999999 + 1, p1: K+1, p2: K+2};
  localparam v4_t E = '{a: 8'd200 >> 1,         p1: K+1, p2: K+2};
  localparam v4_t F = '{a: 8'sd200 >>> 1,       p1: K+1, p2: K+2};
  localparam v4_t G = '{a: 64'hFFFFFFFFFFFFFFFF + 1, p1: K+1, p2: K+2};
  localparam v4_t H = '{a: 8'hFF + 1,           p1: K+1, p2: K+2};
  localparam v4_t I = '{a: 'd5 + 1,             p1: K+1, p2: K+2};
  localparam v4_t J = '{a: 2 * 8'sd200,         p1: K+1, p2: K+2};
  localparam v4_t L = '{a: 8'sd200 & 8'hFF,     p1: K+1, p2: K+2};
  localparam v4_t M = '{a: 8'sd200 - 300,       p1: K+1, p2: K+2};
  localparam v4_t N = '{a: K * 2,               p1: K+1, p2: K+2}; // CONTROL
  localparam v4_t O = '{a: 96'd5 + 1,           p1: K+1, p2: K+2};
  localparam v4_t P = '{a: 65'd36893488147419103232 + 1, p1: K+1, p2: K+2};
endpackage
module v4val76 #(parameter v4::v4_t CA = v4::A, parameter v4::v4_t CB = v4::B,
                 parameter v4::v4_t CC = v4::C, parameter v4::v4_t CD = v4::D,
                 parameter v4::v4_t CE = v4::E, parameter v4::v4_t CF = v4::F,
                 parameter v4::v4_t CG = v4::G, parameter v4::v4_t CH = v4::H,
                 parameter v4::v4_t CI = v4::I, parameter v4::v4_t CJ = v4::J,
                 parameter v4::v4_t CL = v4::L, parameter v4::v4_t CM = v4::M,
                 parameter v4::v4_t CN = v4::N, parameter v4::v4_t CO = v4::O,
                 parameter v4::v4_t CP = v4::P)
                (output logic [63:0] a1, output logic [7:0] b1, output logic [7:0] c1,
                 output logic [63:0] a2, output logic [7:0] b2, output logic [7:0] c2,
                 output logic [63:0] a3, output logic [7:0] b3, output logic [7:0] c3,
                 output logic [63:0] a4, output logic [7:0] b4, output logic [7:0] c4,
                 output logic [63:0] a5, output logic [7:0] b5, output logic [7:0] c5,
                 output logic [63:0] a6, output logic [7:0] b6, output logic [7:0] c6,
                 output logic [63:0] a7, output logic [7:0] b7, output logic [7:0] c7,
                 output logic [63:0] a8, output logic [7:0] b8, output logic [7:0] c8,
                 output logic [63:0] a9, output logic [7:0] b9, output logic [7:0] c9,
                 output logic [63:0] a10,output logic [7:0] b10,output logic [7:0] c10,
                 output logic [63:0] a11,output logic [7:0] b11,output logic [7:0] c11,
                 output logic [63:0] a12,output logic [7:0] b12,output logic [7:0] c12,
                 output logic [63:0] a13,output logic [7:0] b13,output logic [7:0] c13,
                 output logic [63:0] a14,output logic [7:0] b14,output logic [7:0] c14,
                 output logic [63:0] a15,output logic [7:0] b15,output logic [7:0] c15);
  assign a1 = CA.a; assign b1 = CA.p1; assign c1 = CA.p2;
  assign a2 = CB.a; assign b2 = CB.p1; assign c2 = CB.p2;
  assign a3 = CC.a; assign b3 = CC.p1; assign c3 = CC.p2;
  assign a4 = CD.a; assign b4 = CD.p1; assign c4 = CD.p2;
  assign a5 = CE.a; assign b5 = CE.p1; assign c5 = CE.p2;
  assign a6 = CF.a; assign b6 = CF.p1; assign c6 = CF.p2;
  assign a7 = CG.a; assign b7 = CG.p1; assign c7 = CG.p2;
  assign a8 = CH.a; assign b8 = CH.p1; assign c8 = CH.p2;
  assign a9 = CI.a; assign b9 = CI.p1; assign c9 = CI.p2;
  assign a10= CJ.a; assign b10= CJ.p1; assign c10= CJ.p2;
  assign a11= CL.a; assign b11= CL.p1; assign c11= CL.p2;
  assign a12= CM.a; assign b12= CM.p1; assign c12= CM.p2;
  assign a13= CN.a; assign b13= CN.p1; assign c13= CN.p2;
  assign a14= CO.a; assign b14= CO.p1; assign c14= CO.p2;
  assign a15= CP.a; assign b15= CP.p1; assign c15= CP.p2;
endmodule

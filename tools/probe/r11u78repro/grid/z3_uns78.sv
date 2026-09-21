// r11u78 arm z3 — THE UNSIGNED ARM'S VALUE HALF (r11u76's R0).  The landed
// § patOperandEncReduceTable66 value writer is gated on
// `caSubstLeafCt56(setter) == vpiIntConst`; an operand golden encodes
// `vpiUIntConst` keeps the generic branch's MEMBER-MASKED slang value.  The
// producer's own arms mint `UINT:` from the SAME int64 arithmetic over the
// SAME written-digit leaves (ExprEval.cpp:3167-3178 and the b/o/h leaves at
// :1969/:1984/:1998), so the value is `red72Int64`'s answer printed unsigned.
// Members are 64 bits; `p1`/`p2` probe the member stamp.
package z3;
  localparam int K = 6;
  localparam int unsigned KU = 6;
  localparam int LA = K + 1;      // an INT-encoded name
  localparam     LH = 32'h28;     // a HEX-encoded name
  typedef struct packed {
    logic [63:0] a;
    logic [7:0]  p1;
    logic [7:0]  p2;
  } z3_t;
  // --- the five R0 cells ---------------------------------------------------
  localparam z3_t A = '{a: 2'b111 + 1,   p1: K+1, p2: K+2}; // golden UINT:8
  localparam z3_t B = '{a: 3'o77 + 1,    p1: K+1, p2: K+2}; // golden UINT:64
  localparam z3_t C = '{a: 4'hFF + 1,    p1: K+1, p2: K+2}; // golden UINT:256
  localparam z3_t D = '{a: 8'shC8 + 1,   p1: K+1, p2: K+2}; // golden UINT:201
  localparam z3_t E = '{a: 3'so7 + 1,    p1: K+1, p2: K+2}; // golden UINT:8
  // --- the same face at other widths and shapes ---------------------------
  localparam z3_t F = '{a: 4'sb1111 + 1, p1: K+1, p2: K+2}; // 16
  localparam z3_t G = '{a: 8'hC8 + 1,    p1: K+1, p2: K+2}; // 201 (unsigned)
  localparam z3_t H = '{a: 16'hFFFF + 1, p1: K+1, p2: K+2}; // 65536
  localparam z3_t I = '{a: 2'b11 + 2'b11, p1: K+1, p2: K+2}; // 6
  localparam z3_t J = '{a: 1'b1 + 1'b1,  p1: K+1, p2: K+2}; // 2
  // --- the CONTROLS that must not move ------------------------------------
  localparam z3_t L = '{a: LA + 1,       p1: K+1, p2: K+2}; // CTL UINT:8
  localparam z3_t M = '{a: LH + 1,       p1: K+1, p2: K+2}; // CTL UINT:41
  localparam z3_t N = '{a: KU + 1,       p1: K+1, p2: K+2}; // CTL UINT:7
  localparam z3_t O = '{a: 4'd3 + 1,     p1: K+1, p2: K+2}; // CTL UINT:4
  localparam z3_t P = '{a: K * 2,        p1: K+1, p2: K+2}; // CTL INT:12
  localparam z3_t Q = '{a: 8'hAx + 1,    p1: K+1, p2: K+2}; // the UNKNOWN face
endpackage
module z3_uns78 #(parameter z3::z3_t CA = z3::A, parameter z3::z3_t CB = z3::B,
                  parameter z3::z3_t CC = z3::C, parameter z3::z3_t CD = z3::D,
                  parameter z3::z3_t CE = z3::E, parameter z3::z3_t CF = z3::F,
                  parameter z3::z3_t CG = z3::G, parameter z3::z3_t CH = z3::H,
                  parameter z3::z3_t CI = z3::I, parameter z3::z3_t CJ = z3::J,
                  parameter z3::z3_t CL = z3::L, parameter z3::z3_t CM = z3::M,
                  parameter z3::z3_t CN = z3::N, parameter z3::z3_t CO = z3::O,
                  parameter z3::z3_t CP = z3::P, parameter z3::z3_t CQ = z3::Q)
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
                  output logic [7:0]  b16, output logic [7:0] c16);
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
endmodule

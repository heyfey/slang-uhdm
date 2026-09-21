// r11u73 arm w5 — IS § patBailNegCorroborated68v STILL LIVE AFTER LAW A?
// The fence stops the LEADING-MINUS face of `get_uvalue`'s refusal from firing
// on a negative WE produced by wrapping.  Closing r11u72's R0 removes the `**`
// past-int64 abstention that r11u72 kept it for, so the question is whether
// ANY abstention class remains that slang evaluates NEGATIVE while the
// producer's own reduce is POSITIVE.  `red72Int64` models `+ - * / % **` and
// unary `-` only; `<<`, `<<<`, `|`, `&`, `^` and `?:` are all Unknown, and
// `reduceExpr` runs every one of them in `int64_t` over the reduced operands
// (`ExprEval.cpp:3499` `<<`, `:3575` `|`, the conditional arm at `:3898`).
// Operand 0 is the candidate; `K+1`/`K+2` on 8-bit members are the probes
// (8 = golden completed, 64 = golden bailed).  Each member read EXACTLY ONCE.
package q5;
  localparam int K   = 6;
  localparam int BIG = 2000000000;
  typedef struct packed {
    logic [31:0] a;
    logic [7:0]  p1;
    logic [7:0]  p2;
  } f_t;
  localparam f_t A = '{a: BIG << 1,             p1: K+1, p2: K+2};
  localparam f_t B = '{a: (BIG * 2) | 32'd0,    p1: K+1, p2: K+2};
  localparam f_t C = '{a: (K > 0) ? BIG * 2 : 32'd0, p1: K+1, p2: K+2};
  localparam f_t D = '{a: BIG <<< 1,            p1: K+1, p2: K+2};
  localparam f_t E = '{a: (BIG * 2) & 32'hFFFFFFFF, p1: K+1, p2: K+2};
  localparam f_t F = '{a: K * 2,                p1: K+1, p2: K+2}; // CONTROL
  localparam f_t G = '{a: 0 - 32'd100,          p1: K+1, p2: K+2}; // HONEST minus
endpackage
module w5_fence73 #(parameter q5::f_t CA = q5::A, parameter q5::f_t CB = q5::B,
                    parameter q5::f_t CC = q5::C, parameter q5::f_t CD = q5::D,
                    parameter q5::f_t CE = q5::E, parameter q5::f_t CF = q5::F,
                    parameter q5::f_t CG = q5::G)
                   (output logic [31:0] a1, output logic [7:0] b1,
                    output logic [7:0] c1, output logic [31:0] a2,
                    output logic [7:0] b2, output logic [7:0] c2,
                    output logic [31:0] a3, output logic [7:0] b3,
                    output logic [7:0] c3, output logic [31:0] a4,
                    output logic [7:0] b4, output logic [7:0] c4,
                    output logic [31:0] a5, output logic [7:0] b5,
                    output logic [7:0] c5, output logic [31:0] a6,
                    output logic [7:0] b6, output logic [7:0] c6,
                    output logic [31:0] a7, output logic [7:0] b7,
                    output logic [7:0] c7);
  assign a1 = CA.a; assign b1 = CA.p1; assign c1 = CA.p2;
  assign a2 = CB.a; assign b2 = CB.p1; assign c2 = CB.p2;
  assign a3 = CC.a; assign b3 = CC.p1; assign c3 = CC.p2;
  assign a4 = CD.a; assign b4 = CD.p1; assign c4 = CD.p2;
  assign a5 = CE.a; assign b5 = CE.p1; assign c5 = CE.p2;
  assign a6 = CF.a; assign b6 = CF.p1; assign c6 = CF.p2;
  assign a7 = CG.a; assign b7 = CG.p1; assign c7 = CG.p2;
endmodule

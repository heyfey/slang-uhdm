// r11u72 arm t7 — DOES § patBailNegCorroborated68v STILL EARN ITS KEEP?
// The fence stops the LEADING-MINUS face of `get_uvalue`'s refusal from firing
// on a negative WE produced by wrapping.  Once the value half is the
// producer's own int64 answer the fence is a tautology wherever that answer
// exists — so the only cells that can still separate the two are the ones
// § patOperandIntSixtyFour72 ABSTAINS on and slang's own evaluation writes a
// MINUS for.  The `**` arm past int64 is that class (the producer's render
// there is a `static_cast` out-of-range artefact, which the table declines to
// transcribe).
// Operand 0 is the candidate; operands 1..2 are `K+1` probes on 8-bit members,
// so golden's SIZE reads the refusal directly (8 = completed, 64 = bailed).
// Each member read EXACTLY ONCE.
package q7;
  localparam int K = 6;
  typedef struct packed {
    logic [31:0] a;
    logic [7:0]  p1;
    logic [7:0]  p2;
  } f_t;
  localparam f_t A = '{a: 2 ** 31,  p1: K+1, p2: K+2};  // int64 +2147483648, slang int32 NEGATIVE
  localparam f_t B = '{a: 3 ** 40,  p1: K+1, p2: K+2};  // BEYOND int64, slang wraps
  localparam f_t C = '{a: 2 ** 63,  p1: K+1, p2: K+2};  // BEYOND int64 exactly
  localparam f_t D = '{a: 7 ** 23,  p1: K+1, p2: K+2};  // BEYOND int64
  localparam f_t E = '{a: 2 ** 40,  p1: K+1, p2: K+2};  // int64 +1099511627776 (control)
  localparam f_t F = '{a: K * 2,    p1: K+1, p2: K+2};  // no-bail POSITIVE CONTROL
endpackage
module t7_fence72 #(parameter q7::f_t CA = q7::A, parameter q7::f_t CB = q7::B,
                    parameter q7::f_t CC = q7::C, parameter q7::f_t CD = q7::D,
                    parameter q7::f_t CE = q7::E, parameter q7::f_t CF = q7::F)
                   (output logic [31:0] a1, output logic [7:0] b1,
                    output logic [7:0] c1, output logic [31:0] a2,
                    output logic [7:0] b2, output logic [7:0] c2,
                    output logic [31:0] a3, output logic [7:0] b3,
                    output logic [7:0] c3, output logic [31:0] a4,
                    output logic [7:0] b4, output logic [7:0] c4,
                    output logic [31:0] a5, output logic [7:0] b5,
                    output logic [7:0] c5, output logic [31:0] a6,
                    output logic [7:0] b6, output logic [7:0] c6);
  assign a1 = CA.a; assign b1 = CA.p1; assign c1 = CA.p2;
  assign a2 = CB.a; assign b2 = CB.p1; assign c2 = CB.p2;
  assign a3 = CC.a; assign b3 = CC.p1; assign c3 = CC.p2;
  assign a4 = CD.a; assign b4 = CD.p1; assign c4 = CD.p2;
  assign a5 = CE.a; assign b5 = CE.p1; assign c5 = CE.p2;
  assign a6 = CF.a; assign b6 = CF.p1; assign c6 = CF.p2;
endmodule

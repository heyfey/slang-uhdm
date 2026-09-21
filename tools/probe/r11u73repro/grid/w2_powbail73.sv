// r11u73 arm w2 — THE `**` ARM'S BAIL FACE, AND ITS POST-BAIL SIZE (LAW A/B).
// Operand 0 is the candidate; operands 1..2 are `K+1`/`K+2` on 8-bit members,
// so golden's stamped SIZE reads the producer's refusal directly: 8 = the walk
// completed and stamped the member width, 64 = `expandPatternAssignment`
// bailed at operand 0 and the probes keep `reduceExpr`'s own size.
// The out-of-range cast artefact is NEGATIVE, so `get_uvalue` refuses it and
// every artefact cell must read 64 golden-side.  The in-range `**` cells must
// read 8.  Each member read EXACTLY ONCE.
package q2;
  localparam int K = 6;
  typedef struct packed {
    logic [63:0] a;
    logic [7:0]  p1;
    logic [7:0]  p2;
  } p_t;
  localparam p_t A = '{a: 2 ** 64,  p1: K+1, p2: K+2};  // artefact -> bail
  localparam p_t B = '{a: 3 ** 39,  p1: K+1, p2: K+2};  // rounded, positive
  localparam p_t C = '{a: 2 ** 63,  p1: K+1, p2: K+2};  // artefact -> bail
  localparam p_t D = '{a: 2 ** 62,  p1: K+1, p2: K+2};  // in range, positive
  localparam p_t E = '{a: (-2)**63, p1: K+1, p2: K+2};  // IN range, negative
  localparam p_t F = '{a: K * 2,    p1: K+1, p2: K+2};  // no-bail CONTROL
endpackage
// The SIZE face: operand 0 is a guaranteed bail (`8'hxA`, r11u68 `b1`), so
// every operand after it prints `reduceExpr`'s OWN size against 24-bit members
// that collide with nothing.  The `**` arm writes `VpiSize(64)`.
package q2b;
  localparam int K = 6;
  typedef struct packed {
    logic [23:0] bail;  // 8'hxA   GUARANTEED BAIL
    logic [23:0] a;     // 3 ** 39   the `**` arm's own size
    logic [23:0] b;     // 2 ** 62   the `**` arm's own size
    logic [23:0] c;     // K * 2     the `*` arm's own size (64, r11u68)
    logic [23:0] d;     // K + 1     the `+` arm: max(l,r)
    logic [23:0] e;     // K         a NAME: the declared width
  } c2_t;
  localparam c2_t A2 = '{bail: 8'hxA, a: 3**39, b: 2**62, c: K*2, d: K+1, e: K};
endpackage
module w2_powbail73 #(parameter q2::p_t CA = q2::A, parameter q2::p_t CB = q2::B,
                      parameter q2::p_t CC = q2::C, parameter q2::p_t CD = q2::D,
                      parameter q2::p_t CE = q2::E, parameter q2::p_t CF = q2::F,
                      parameter q2b::c2_t CS = q2b::A2)
                     (output logic [63:0] a1, output logic [7:0] b1,
                      output logic [7:0] c1, output logic [63:0] a2,
                      output logic [7:0] b2, output logic [7:0] c2,
                      output logic [63:0] a3, output logic [7:0] b3,
                      output logic [7:0] c3, output logic [63:0] a4,
                      output logic [7:0] b4, output logic [7:0] c4,
                      output logic [63:0] a5, output logic [7:0] b5,
                      output logic [7:0] c5, output logic [63:0] a6,
                      output logic [7:0] b6, output logic [7:0] c6,
                      output logic [23:0] s0, output logic [23:0] s1,
                      output logic [23:0] s2, output logic [23:0] s3,
                      output logic [23:0] s4, output logic [23:0] s5);
  assign a1 = CA.a; assign b1 = CA.p1; assign c1 = CA.p2;
  assign a2 = CB.a; assign b2 = CB.p1; assign c2 = CB.p2;
  assign a3 = CC.a; assign b3 = CC.p1; assign c3 = CC.p2;
  assign a4 = CD.a; assign b4 = CD.p1; assign c4 = CD.p2;
  assign a5 = CE.a; assign b5 = CE.p1; assign c5 = CE.p2;
  assign a6 = CF.a; assign b6 = CF.p1; assign c6 = CF.p2;
  assign s0 = CS.bail; assign s1 = CS.a; assign s2 = CS.b;
  assign s3 = CS.c;    assign s4 = CS.d; assign s5 = CS.e;
endmodule

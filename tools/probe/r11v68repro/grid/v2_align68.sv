// v11u68 ADVERSARIAL arm v2 — LAW A OPERAND-INDEX ALIGNMENT.
// `opSet68` pairs our emitted operands with their setters by FLUSHING the
// previous field's setter.  Anything that makes our operand list a different
// SHAPE from golden's -- an `'x`/`'z` member that reaches no constant, a
// nested pattern, a packed-array member that may flatten, a `default:` fill
// interleaved with named setters -- can slide the bail INDEX and stamp the
// reduce size on an operand golden stamped at the member width.
// Controls are `K + 1` (reduce size 64) on 8-bit members: golden 8 =
// completed, 64 = post-bail.
package qa;
  localparam int K = 6;
  localparam int unsigned KU = 6;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } inn_t;
  typedef struct packed {
    logic [7:0] m0; logic [7:0] m1; logic [7:0] m2; logic [7:0] m3;
    logic [7:0] m4; logic [7:0] m5;
  } s6_t;
  typedef struct packed {
    logic [7:0] m0; inn_t m1; logic [7:0] m2; logic [7:0] m3;
  } sn_t;
  typedef struct packed {
    logic [7:0] m0; logic [1:0][7:0] m1; logic [7:0] m2; logic [7:0] m3;
  } sa_t;
  typedef struct packed {
    logic [7:0] m0; logic [7:0] m1; logic [7:0] m2; logic [7:0] m3;
  } s4_t;
  // A1: 'x in the MIDDLE, bail at op0 (the XOR).  Does our index slide?
  localparam s6_t A1 = '{m0: KU ^ 3, m1: 8'bx, m2: K + 1, m3: K + 1, m4: K + 1, m5: K + 1};
  // A2: 'x in the MIDDLE, NO bail before it -- the 'x IS the bail in golden.
  localparam s6_t A2 = '{m0: 8'd5, m1: 8'bx, m2: K + 1, m3: K + 1, m4: K + 1, m5: K + 1};
  // A3: 'z in the middle behind a valid digit (8'b1z -> leading 1, NO bail).
  localparam s6_t A3 = '{m0: 8'd5, m1: 8'b1z, m2: K + 1, m3: K + 1, m4: K + 1, m5: K + 1};
  // A4: two unknowns, then controls.
  localparam s6_t A4 = '{m0: 8'bx, m1: 8'bz, m2: K + 1, m3: K + 1, m4: K + 1, m5: K + 1};
  // A5: a NESTED pattern at m1, controls after.
  localparam sn_t A5 = '{m0: 8'd5, m1: '{a: 8'd1, b: 8'd2}, m2: K + 1, m3: K + 1};
  // A6: a nested pattern at m1 AND a bail at m0.
  localparam sn_t A6 = '{m0: KU ^ 3, m1: '{a: 8'd1, b: 8'd2}, m2: K + 1, m3: K + 1};
  // A7: a PACKED ARRAY member at m1 set by a pattern, controls after.
  localparam sa_t A7 = '{m0: 8'd5, m1: '{8'd1, 8'd2}, m2: K + 1, m3: K + 1};
  // A8: the same with a bail at m0.
  localparam sa_t A8 = '{m0: KU ^ 3, m1: '{8'd1, 8'd2}, m2: K + 1, m3: K + 1};
  // A9: a `default:` fill with NAMED setters around it and a bail.
  localparam s4_t A9 = '{m0: KU ^ 3, m2: K + 1, default: 9};
  // A10: `default:` only.
  localparam s4_t A10 = '{default: K + 1};
  // A11: a bail at the LAST operand (nothing after -- must be a no-op).
  localparam s4_t A11 = '{m0: K + 1, m1: K + 1, m2: K + 1, m3: KU ^ 3};
  // A12: TWO bails, controls between and after.
  localparam s6_t A12 = '{m0: KU ^ 3, m1: K + 1, m2: -K, m3: K + 1, m4: K + 1, m5: K + 1};
  // A13: no bail at all -- the POSITIVE CONTROL for this arm.
  localparam s6_t A13 = '{m0: 8'd5, m1: K + 1, m2: K + 1, m3: K + 1, m4: K + 1, m5: K + 1};
  // A14: a bail at m0 and a STRING after it.
  localparam s6_t A14 = '{m0: KU ^ 3, m1: "a", m2: K + 1, m3: K + 1, m4: K + 1, m5: K + 1};
  // A15: a bail at m0, then operands of many kinds (post-bail SIZE table).
  localparam s6_t A15 = '{m0: KU ^ 3, m1: 4'd3, m2: 96'h1, m3: K, m4: KU + 1, m5: -K};
endpackage
module v2_align68 #(parameter qa::s6_t C1 = qa::A1, parameter qa::s6_t C2 = qa::A2,
                    parameter qa::s6_t C3 = qa::A3, parameter qa::s6_t C4 = qa::A4,
                    parameter qa::sn_t C5 = qa::A5, parameter qa::sn_t C6 = qa::A6,
                    parameter qa::sa_t C7 = qa::A7, parameter qa::sa_t C8 = qa::A8,
                    parameter qa::s4_t C9 = qa::A9, parameter qa::s4_t C10 = qa::A10,
                    parameter qa::s4_t C11 = qa::A11, parameter qa::s6_t C12 = qa::A12,
                    parameter qa::s6_t C13 = qa::A13, parameter qa::s6_t C14 = qa::A14,
                    parameter qa::s6_t C15 = qa::A15)
                   (output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3,
                    output logic [7:0] o4, output logic [7:0] o5, output logic [7:0] o6,
                    output logic [7:0] o7, output logic [7:0] o8, output logic [7:0] o9,
                    output logic [7:0] o10, output logic [7:0] o11, output logic [7:0] o12,
                    output logic [7:0] o13, output logic [7:0] o14, output logic [7:0] o15);
  assign o1 = C1.m2;  assign o2 = C2.m2;  assign o3 = C3.m2;  assign o4 = C4.m2;
  assign o5 = C5.m2;  assign o6 = C6.m2;  assign o7 = C7.m2;  assign o8 = C8.m2;
  assign o9 = C9.m2;  assign o10 = C10.m2; assign o11 = C11.m2; assign o12 = C12.m3;
  assign o13 = C13.m2; assign o14 = C14.m2; assign o15 = C15.m3;
endmodule

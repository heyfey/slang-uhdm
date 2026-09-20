// v11u72 BREAK ARM 4 — THE NAME HOP AND ITS GUARD.  `red72Int64` follows a
// NAME into its INITIALIZER and accepts the initializer's int64 answer when
// the name's own value agrees modulo the name's width.  The classes that can
// separate the two: an OVERRIDDEN parameter (the guard's stated target), a
// parameter whose declared width TRUNCATES its initializer, a chain of hops,
// an enum member with a negative initializer, and a name whose initializer is
// itself an unsigned wrap.  Each member read EXACTLY ONCE.
package p4;
  localparam int         K    = 6;
  localparam bit [31:0]  KU   = 3;
  localparam bit [7:0]   TR   = 8'(KU - 5);   // TRUNCATED to 8 bits: 254
  localparam             MD   = -16'd5;       // untyped minus (golden INT:-5)
  localparam bit [15:0]  WRAP = KU - 5;       // declared 16: slang 65534
  localparam             HOP1 = MD;           // one more hop
  localparam             HOP2 = HOP1;         // two more hops
  typedef enum logic [7:0] { EA = 8'd7, EB = 8'hF } e_t;
  typedef struct packed {
    logic [31:0] a;  // TR      declared 8, initializer int64 -2
    logic [31:0] b;  // WRAP    declared 16, initializer int64 -2
    logic [31:0] c;  // HOP2    two hops onto -5
    logic [31:0] d;  // EA      an enum member
    logic [31:0] e;  // EB      an enum member, hex initializer
    logic [31:0] f;  // MD + 0  the name inside an arm
    logic [31:0] g;  // K       CONTROL
  } c_t;
  localparam c_t A = '{a: TR, b: WRAP, c: HOP2, d: EA, e: EB, f: MD + 0, g: K};
endpackage
module v4_sub #(parameter int P = -8) (output logic [31:0] z);
  typedef struct packed { logic [31:0] q; logic [31:0] r; } s_t;
  localparam s_t S = '{q: P, r: P * 2};
  assign z = S.q + S.r;
endmodule
module v4_hop72 #(parameter p4::c_t C = p4::A)
                (output logic [31:0] y0, output logic [31:0] y1,
                 output logic [31:0] y2, output logic [31:0] y3,
                 output logic [31:0] y4, output logic [31:0] y5,
                 output logic [31:0] y6, output logic [31:0] y7);
  assign y0 = C.a; assign y1 = C.b; assign y2 = C.c; assign y3 = C.d;
  assign y4 = C.e; assign y5 = C.f; assign y6 = C.g;
  v4_sub #(.P(2000000000 * 2)) u1 (.z(y7));
endmodule

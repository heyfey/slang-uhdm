// r11u87 arm y6 — WHICH EXPRESSION SIZES AN OVERRIDDEN HOP.  The override is
// compiled in the PARENT and stored on the child instance without
// `adjustSize`, so the store's width is the OVERRIDE literal's, not the
// default's and not the declared type's.  Each override here is written at a
// DIFFERENT width from its default so the two answers cannot be confused.
package y6p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
endpackage
module y6_ovw87;
  y6_mid #(.P(32'd9), .Q(16'o21), .S(9), .T(8'd3)) m1();
  y6_mid                                            m2();
endmodule
module y6_mid #(parameter int P = 16'd5,
                parameter int Q = 32'o7,
                parameter int S = 16'd4,
                parameter logic signed [15:0] T = 16'd1) ();
  localparam y6p::t B = '{bail: 8'hxA, a: P, b: Q, c: S, d: T, e: P, f: Q,
                          g: T};
  y6_sink #(.R(B)) s1();
endmodule
module y6_sink #(parameter y6p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule

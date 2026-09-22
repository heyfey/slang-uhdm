// r11u89 arm w5 — THE OVERRIDE SETS THE WIDTH.  The named override road
// (`DesignElaboration.cpp:2185-2187`) compiles the override expression in the
// PARENT and calls `fromVpiValue(c->VpiValue(), c->VpiSize())` with NO
// `adjustSize` and NO declared typespec — so the store's width is the OVERRIDE
// literal's OWN written width, and `valueRange` never runs (the store stays
// unsigned).  Each override is written at a width that is neither the
// default's nor the declaration's so the three answers cannot be confused.
package w5p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam int PSRC = 20'd11;
endpackage
module w5_ovr87;
  // NAMED overrides, four shapes
  w5_mid #(.P(16'd5), .Q(8'd6), .S(24'o17), .T(4'h3), .U(7), .V(40'd9)) m1();
  // the same module left entirely at its defaults — the STILL section
  w5_mid                                                               m2();
  // POSITIONAL overrides of the same widths
  w5_mid #(12'd4, 20'd6, 9'o17, 5'h3, 8, 33'd9)                        m3();
  // an override that is a package HOP, and one that is an operation
  w5_mid #(.P(w5p::PSRC), .Q(16'd6 + 16'd0))                           m4();
  // the EDGE shapes: an UNSIZED BASED literal, a binary base, a negation,
  // a sized decimal wider than the word, an `s`-marked literal
  w5_mid #(.P('d5), .Q(8'b1010), .S(64'd5), .T(-5), .U(16'sd7), .V(1'b1)) m5();
  // the plain unsized decimal against a NARROW declaration
  w5_nar #(.W(7), .X(4'd3))                                            m6();
  w5_nar                                                               m7();
endmodule
module w5_nar #(parameter logic [3:0] W = 4'd1,
                parameter logic [3:0] X = 4'd2) ();
  localparam w5p::t N = '{bail: 8'hxA, a: W, b: X, c: W, d: X,
                          e: W, f: X, g: W};
  w5_sink #(.R(N)) s2();
endmodule
module w5_mid #(parameter int                 P = 32'd1,
                parameter logic [15:0]        Q = 16'd2,
                parameter int                 S = 32'o3,
                parameter logic [11:0]        T = 12'h4,
                parameter int                 U = 32'd5,
                parameter logic signed [15:0] V = 16'd6) ();
  localparam w5p::t B = '{bail: 8'hxA, a: P, b: Q, c: S, d: T,
                          e: U, f: V, g: P};
  w5_sink #(.R(B)) s1();
endmodule
module w5_sink #(parameter w5p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule

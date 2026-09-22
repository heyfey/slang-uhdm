// r11v89 break arm x3 — LAW C's OVERRIDE EDGES.  The new reader writes
// VpiSize from the override literal: 64 for a plain unsized decimal, the
// written width for a `'d`/`'o`/`'h` vector.  Shapes the implementer's w5
// does not hold: an override inside a GENERATE block, an INTERFACE's
// parameter, a `'h` override wider than the word, an unknown-digit override,
// a zero, and a module overridden in one place and defaulted in another.
package x3p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
endpackage
module x3_ovred89;
  x3_mid #(.P(96'h5), .Q(8'd0), .S(0), .T(4'o7))  m1();
  x3_mid                                          m2();
  if (1) begin : g
    x3_mid #(.P(20'd7), .Q(12'o17), .S(9), .T(5'h3)) m3();
  end
  x3_if  #(.IP(16'd5)) u1();
  x3_if                u2();
endmodule
module x3_mid #(parameter int           P = 32'd1,
                parameter logic [15:0]  Q = 16'd2,
                parameter int           S = 32'd3,
                parameter logic [11:0]  T = 12'h4) ();
  localparam x3p::t C = '{bail: 8'hxA, a: P, b: Q, c: S, d: T,
                          e: P, f: Q, g: S};
  x3_sink #(.R(C)) s1();
endmodule
interface x3_if #(parameter int IP = 32'd1) ();
  localparam x3p::t D = '{bail: 8'hxA, a: IP, b: IP, c: IP, d: IP,
                          e: IP, f: IP, g: IP};
endinterface
module x3_sink #(parameter x3p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule

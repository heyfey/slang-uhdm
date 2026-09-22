// r11u87 arm y2 — THE FACES BESIDE THE PLAIN NAME: a signedness CAST over a
// signed hop, a parameter OVERRIDE, a GENERATE-block home, an INTERFACE home,
// a two-hop chain whose halves disagree, and a declared-UNSIGNED parameter
// whose LITERAL is `s`-marked (the `cts` face of
// `DesignElaboration.cpp:2578-2585`: the constant's OWN typespec, not the
// declaration's, is what `valueRange` reads when the constant has one).
package y2p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
endpackage
module y2_face87;
  localparam int           YIN = 16'd5;
  localparam int           YIO = 16'o17;
  localparam               YDU = 16'd5;
  localparam logic [15:0]  YSL = 16'sd5;    // declared UNSIGNED, `s` literal
  localparam int           YC1 = 16'd5;
  localparam               YC2 = YC1;       // untyped hop over a typed one
  localparam int           YC3 = YDU;       // typed hop over an untyped one
  localparam y2p::t A = '{bail: 8'hxA, a: signed'(YIN), b: unsigned'(YIN),
                          c: $signed(YDU), d: $unsigned(YIN), e: YSL,
                          f: YC2, g: YC3};
  y2_mid #(.P(16'd9), .Q(16'o21)) m1();
  if (1) begin : gb
    localparam int         YGN = 16'd5;
    localparam y2p::t G = '{bail: 8'hxA, a: YGN, b: YIN, c: YIO, d: YDU,
                            e: YGN, f: YIN, g: YIO};
  end
  y2_sink #(.R(A)) s1();
endmodule
module y2_mid #(parameter int P = 16'd5, parameter int Q = 16'o7) ();
  localparam y2p::t B = '{bail: 8'hxA, a: P, b: Q, c: P, d: Q, e: P, f: Q,
                          g: P};
  y2_sink #(.R(B)) s2();
endmodule
interface y2_if87;
  localparam int          YFN = 16'd5;
  localparam signed [15:0] YFS = 16'o17;
  localparam y2p::t I = '{bail: 8'hxA, a: YFN, b: YFS, c: YFN, d: YFS,
                          e: YFN, f: YFS, g: YFN};
endinterface
module y2_sink #(parameter y2p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule

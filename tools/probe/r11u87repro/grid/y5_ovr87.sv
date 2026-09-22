// r11u87 arm y5 — THE OVERRIDE FENCE AND THE OTHER HOMES.  An OVERRIDDEN
// parameter never reaches `DesignElaboration.cpp:2505-2646`'s loop (the
// `overridenParams` guard at :2510), so `valueRange` never runs on it and its
// store is UNSIGNED whatever its declared type says — while the same
// declaration left at its default IS signed.  Two instances of one module,
// one overridden and one not, put the two answers side by side.  The
// generate-block and interface homes are read with the extended lister.
package y5p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
endpackage
module y5_ovr87;
  localparam int          YIN = 16'd5;
  localparam [15:0]       YID = 32'd5;    // implicit + packed dimension
  localparam signed       YIS = 32'd5;    // implicit + signing, no dimension
  localparam y5p::t A = '{bail: 8'hxA, a: YID, b: YIS, c: YIN, d: YID,
                          e: YIS, f: YIN, g: YID};
  y5_mid #(.P(16'd9)) m1();               // OVERRIDDEN
  y5_mid              m2();               // left at the DEFAULT
  if (1) begin : gb
    localparam int      YGN = 16'd5;
    localparam signed [15:0] YGS = 16'o17;
    localparam y5p::t G = '{bail: 8'hxA, a: YGN, b: YGS, c: YIN, d: YGN,
                            e: YGS, f: YIN, g: YGN};
  end
  y5_if87 u();
  y5_sink #(.R(A)) s1();
endmodule
module y5_mid #(parameter int P = 16'd5) ();
  localparam y5p::t B = '{bail: 8'hxA, a: P, b: P, c: P, d: P, e: P, f: P,
                          g: P};
endmodule
interface y5_if87;
  localparam int           YFN = 16'd5;
  localparam signed [15:0] YFS = 16'o17;
  localparam y5p::t I = '{bail: 8'hxA, a: YFN, b: YFS, c: YFN, d: YFS,
                          e: YFN, f: YFS, g: YFN};
endinterface
module y5_sink #(parameter y5p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule

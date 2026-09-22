// r11u89 arm w6 — THE DEFPARAM, A FENCED CONTROL.  slang's ParameterBuilder
// (`ParameterBuilder.cpp:281-292`) sets `DeclaredTypeFlags::InitializerOverridden`
// only for a `#()` / config override; a defparam whose override node carries no
// EXPRESSION takes the early `param->setValue(...)` return, so
// `ParameterSymbol::isOverridden()` reads FALSE while the VALUE is replaced.
// Surelog's defparam road is `DesignElaboration.cpp:2437+`, a third road again.
// This arm MEASURES the shape; the laws of this pass must not move a cell of
// it (the value face is a pre-existing bug on both binaries — r11u87's R3
// caution, its own pass).
package w6p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
endpackage
module w6_dfp89;
  w6_mid m1();
  w6_mid m2();
  defparam m1.P = 16'd5;
  defparam m1.Q = 8'o17;
  defparam m1.V = 16'd9;
endmodule
module w6_mid #(parameter int                 P = 32'd1,
                parameter logic [15:0]        Q = 16'o3,
                parameter logic signed [15:0] V = 16'd6) ();
  localparam logic [7:0] H = P;          // a chain OVER a defparam'd hop
  localparam w6p::t B = '{bail: 8'hxA, a: P, b: Q, c: V, d: H,
                          e: P, f: V, g: Q};
  w6_sink #(.R(B)) s1();
endmodule
module w6_sink #(parameter w6p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule

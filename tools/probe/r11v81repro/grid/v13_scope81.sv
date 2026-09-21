// r11v81 adversarial arm v13 — SAME-PACKAGE vs OTHER-PACKAGE hops inside ONE
// package pattern: local unqualified, local qualified, imported unqualified,
// other-package qualified.
package v13a;
  localparam BH = 16'h5;
endpackage
package v13b;
  import v13a::*;
  localparam LH = 16'h5;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;
  } t13;
  localparam t13 Y = '{bail: 8'hxA, a: LH, b: v13b::LH, c: BH, d: v13a::BH};
endpackage
module v13_scope81 #(parameter v13b::t13 CY = v13b::Y) (output logic [23:0] o);
  assign o = CY.a ^ CY.b ^ CY.c ^ CY.d;
endmodule

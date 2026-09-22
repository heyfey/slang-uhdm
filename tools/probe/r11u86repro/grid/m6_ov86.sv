// r11u86 arm m6 — the OVERRIDE and SCOPE faces of the module-route encoding:
// a hop that is an OVERRIDDEN module parameter, a hop declared in a generate
// block, a hop that is an enum member, and a hop reached through a parameter
// PORT of the pattern's own module.
package m6p;
  localparam PD = 16'd5;
  localparam PO = 16'o17;
  typedef enum logic [23:0] { E0 = 24'd9, E1 = 24'o7 } e6;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;
  } t6;
endpackage
module m6_ov86;
  m6_mid #(.P(16'o21), .Q(m6p::PD)) u1();
endmodule
module m6_mid #(parameter P = 16'd5, parameter Q = 16'd1) ();
  localparam m6p::t6 OVP = '{bail: 8'hxA, a: P, b: Q, c: m6p::PO, d: m6p::PD};
  if (1) begin : g6
    localparam GD = 16'd3;
    localparam m6p::t6 GEN = '{bail: 8'hxA, a: GD, b: P, c: m6p::E0,
                               d: m6p::E1};
  end
endmodule

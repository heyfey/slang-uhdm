// r11v89 break arm x7 — LAW A's RECURSION RETURNS BEFORE THE OUTER'S OWN KIND
// IS LOOKED AT.  The new arm fires on the INNER's signedness alone, so the
// OUTER may be any declared kind at all — `byte`, `shortint`, `integer`,
// `longint`, an implicit declaration carrying only a dimension, a typedef of
// an unsigned vector, an enum.  `valueRange` takes its RANGE off the LHS and
// its SIGNEDNESS off the RHS, so golden should agree; this arm asks.
package x7p;
  typedef logic [15:0] u16_t;
  typedef enum logic [7:0] { E0 = 8'd0, E1 = 8'd1 } e_t;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
endpackage
module x7_outkind89;
  localparam int          C1 = 16'd5;
  localparam [7:0]        K1 = C1;     // implicit, a dimension, no signing
  localparam byte         K2 = C1;
  localparam shortint     K3 = C1;
  localparam integer      K4 = C1;
  localparam longint      K5 = C1;
  localparam x7p::u16_t   K6 = C1;     // a typedef of an UNSIGNED vector
  localparam x7p::e_t     K7 = x7p::e_t'(C1 % 2);
  localparam x7p::t A = '{bail: 8'hxA, a: K1, b: K2, c: K3, d: K4,
                          e: K5, f: K6, g: K7};
  x7_sink #(.R(A)) s1();
endmodule
module x7_sink #(parameter x7p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule

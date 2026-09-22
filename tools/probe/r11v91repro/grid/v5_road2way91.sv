// r11v91 BREAK arm v5 — THE SAME PACKAGE PARAMETER READ BOTH WAYS, and the
// `$unit` name with and without its scope.  If golden's two cells differ, the
// road is the SYNTAX (`paPackage_scope`) and not the symbol's home.
package v5p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam int          KI  = 16'd5;
  localparam logic [11:0] KU  = 16'd6;
endpackage
localparam int KUNIT = 16'd13;
module v5_road2way91;
  import v5p::*;
  localparam logic [7:0] G1 = v5p::KI;     // SCOPED
  localparam logic [7:0] G2 = KI;          // the SAME parameter, IMPORTED bare
  localparam logic [7:0] G3 = v5p::KU;     // SCOPED, unsigned/12
  localparam logic [7:0] G4 = KU;          // IMPORTED bare
  localparam logic [7:0] G5 = KUNIT;       // $unit, bare
  localparam logic [7:0] G6 = $unit::KUNIT;// $unit, SCOPED
  localparam logic signed [15:0] G7 = v5p::KU;  // signed reader, unsigned pkg
  localparam v5p::t A = '{bail: 8'hxA, a: G1, b: G2, c: G3, d: G4,
                          e: G5, f: G6, g: G7};
  v5_sink #(.R(A)) s1();
endmodule
module v5_sink #(parameter v5p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule

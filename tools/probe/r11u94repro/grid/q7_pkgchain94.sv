// r11u94 arm q7 — the SYNTHESIZED typespec seen from ONE HOP FURTHER IN.  A
// PLAIN implicit package hop (kind 0) attaches nothing of its own, so the
// clone it passes on carries the INNER's typespec and width — and when that
// inner is a kind-2 declaration the answer must be the synthesiser's, not the
// literal's.  The three recursions of `§ modPkgFedHopStore91` (sign, width,
// has-a-typespec) each have to reach it.
package q7p;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
  localparam signed        Y1 = 16'd5;   // kind 2, signed, no dimension
  localparam unsigned      Y2 = 16'd6;   // kind 2, unsigned
  localparam        [11:0] Y3 = 16'd7;   // kind 2, a dimension alone
  localparam               Z1 = Y1;      // kind 0 over a kind-2 SIGNED
  localparam               Z2 = Y2;      // kind 0 over a kind-2 UNSIGNED
  localparam               Z3 = Y3;      // kind 0 over a kind-2 DIMENSION
  localparam int           Z4 = Y1;      // kind 1 over a kind 2
  localparam signed        Z5 = Y3;      // kind 2 over a kind 2
endpackage
module q7_pkgchain94;
  localparam logic [7:0] X1 = q7p::Z1;
  localparam logic [7:0] X2 = q7p::Z2;
  localparam logic [7:0] X3 = q7p::Z3;
  localparam logic [7:0] X4 = q7p::Z4;
  localparam logic [7:0] X5 = q7p::Z5;
  localparam logic [7:0] X6 = q7p::Y1;
  localparam logic [7:0] X7 = q7p::Y3;
  localparam q7p::t A = '{bail: 8'hxA, a: X1, b: X2, c: X3, d: X4,
                          e: X5, f: X6, g: X7};
  q7_sink #(.R(A)) s1();
endmodule
module q7_sink #(parameter q7p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule

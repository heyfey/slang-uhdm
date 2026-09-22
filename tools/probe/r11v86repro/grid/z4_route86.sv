// VERIFIER arm z4 — ROUTES THE LANDED GRID DID NOT WALK.  Every setter here is
// an UNQUALIFIED module-bare NAME so the law's hop gate opens, but the chain
// crosses a boundary the producer may route differently:
//   a  a module localparam whose OWN initializer is a package-qualified hop
//   b  an imported-bare package parameter
//   c  a module PORT parameter overridden at the instance with a `'d` spelling
//   d  a module PORT parameter left at its `'o` default
//   e  a chain through a localparam declared AFTER the pattern
//   f  a hop whose initializer is an operation over two `'d` literals
//   g  a hop to a parameter whose initializer is a width CAST over a `'d`
package z4p;
  localparam ZPD = 16'd5;
  localparam ZPO = 16'o5;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
    logic [23:0] d;    logic [23:0] e; logic [23:0] f; logic [23:0] g;
  } t;
endpackage
import z4p::ZPO;
module z4_route86;
  localparam ZA = z4p::ZPD;
  localparam ZB = ZPO;
  localparam ZF = 16'd9 + 16'd1;
  localparam ZG = 16'(16'd5);
  localparam ZE = ZA;
  localparam z4p::t Z = '{bail: 8'hxA, a: ZA, b: ZB, c: 16'd0, d: 16'o0,
                          e: ZE, f: ZF, g: ZG};
  z4_mid #(.P(16'd21), .Q(z4p::ZPO)) m1();
  z4_sink #(.R(Z)) s1();
endmodule
module z4_mid #(parameter P = 16'o7, parameter Q = 16'd3);
  localparam z4p::t ZM = '{bail: 8'hxA, a: P, b: Q, c: 16'd1, d: 16'o1,
                           e: P, f: Q, g: 16'd2};
  z4_sink #(.R(ZM)) s2();
endmodule
module z4_sink #(parameter z4p::t R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule

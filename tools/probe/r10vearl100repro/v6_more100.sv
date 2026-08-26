// v100 arm 6 — the remaining faces: struct member read only / written both
// ways, a typedef-of-a-package-typedef port, a port carried through THREE
// nesting levels, a struct port next to a NON-net-like one in the same
// module, an anonymous packed-struct port, and a body decl of the same
// typedef in the same module (net vs port interaction).
package vp6;
  typedef struct packed { logic [7:0] a; logic [7:0] b; }  base_t;
  typedef base_t                                           alias_t;   // alias of a pkg alias
  typedef enum logic { Y0, Y1 } y_t;
  typedef struct packed { logic [6:0] c; y_t d; }          ev_t;      // enum member
endpackage

module v6_l3 import vp6::*; (input alias_t p, output logic [7:0] o);
  assign o = p.a;                       // read only
endmodule

module v6_l2 import vp6::*; (input alias_t p, output logic [7:0] o);
  v6_l3 u3 (.p(p), .o(o));
endmodule

module v6_l1 import vp6::*; (input alias_t p, output logic [7:0] o);
  v6_l2 u2 (.p(p), .o(o));
endmodule

// both procedural and continuous writes to different struct ports, plus a
// non-net-like struct port in the same module, plus a body decl of the same type
module v6_mix import vp6::*; (input base_t pi, output base_t po1, output base_t po2,
                              input ev_t pe, output logic [7:0] o);
  base_t body_same;
  always_comb po1 = pi;                 // blocking -> route fired in pristine
  assign     po2 = pi;
  assign     body_same = pi;
  assign     o = pe.c ^ body_same.a;
endmodule

// anonymous packed struct port (not a package typedef -> route never reached)
module v6_anon (input struct packed { logic [7:0] a; logic [7:0] b; } p,
                output logic [7:0] o);
  assign o = p.a;
endmodule

module v6_more100 import vp6::*; ();
  alias_t z1;
  base_t  z2, z3, z4, z5;
  ev_t    z6;
  logic [7:0] q1, q2, q3;
  v6_l1   u_l1  (.p(z1), .o(q1));
  v6_mix  u_mix (.pi(z2), .po1(z3), .po2(z4), .pe(z6), .o(q2));
  v6_anon u_an  (.p(z5), .o(q3));
  assign z1 = '0; assign z2 = '0; assign z5 = '0; assign z6 = '0;
endmodule

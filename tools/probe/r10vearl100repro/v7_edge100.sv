// v100 arm 7 — the edges: `default_nettype none`, macro-expanded PORT
// declarations, mixed bare / pkg::-qualified spelling in ONE module, an
// anonymous nested struct member (the usbdev shape), a `bit` member, a
// parameter-width logic member, and an `ifdef`-selected declaration.
`define PORTPAIR(T,N) input T N``_i, output T N``_o
package vp7;
  parameter int PW = 8;
  typedef struct packed { logic [PW-1:0] a; logic [PW-1:0] b; }  pw_t;   // parameter width
  typedef struct packed {
    struct packed { logic q; } m0;
    struct packed { logic q; } m1;
  }                                                              anon_t;  // usbdev shape
  typedef struct packed { logic [7:0] a; bit b; }                bitm_t;  // bit member -> VAR
  typedef struct packed { logic [7:0] a; logic [7:0] b; }        pl_t;
endpackage

`default_nettype none
module v7_none import vp7::*; (input pl_t p, output logic [7:0] o);
  assign o = p.a;
endmodule
`default_nettype wire

module v7_macro import vp7::*; (`PORTPAIR(pl_t, m), `PORTPAIR(anon_t, n),
                                output logic o);
  always_comb m_o = m_i;              // blocking write -> route fired in pristine
  assign n_o = n_i;
  assign o = m_i.a[0];
endmodule

// bare AND pkg::-qualified spelling of the same typedef in one module
module v7_mixed import vp7::*; (input pl_t bare_p, input vp7::pl_t qual_p,
                                input bitm_t bm, input pw_t pw,
                                output logic [7:0] o);
  assign o = bare_p.a ^ qual_p.b ^ bm.a ^ pw.a;
endmodule

module v7_edge100 import vp7::*; ();
  pl_t   c1, c2, c3, c4;
  anon_t c5, c6;
  bitm_t c7;
  pw_t   c8;
  logic [7:0] y1, y2;
  logic       y3;
  v7_none  u_nn (.p(c1), .o(y1));
  v7_macro u_mc (.m_i(c2), .m_o(c3), .n_i(c5), .n_o(c6), .o(y3));
  v7_mixed u_mx (.bare_p(c4), .qual_p(c4), .bm(c7), .pw(c8), .o(y2));
  assign c1 = '0; assign c2 = '0; assign c4 = '0; assign c5 = '0;
  assign c7 = '0; assign c8 = '0;
endmodule

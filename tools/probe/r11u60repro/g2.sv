// g2 — THE MIRROR ARM, UNPACKED (the corpus face).
package p2;
  typedef struct { int unsigned a; int unsigned b; } ub_t;
  localparam ub_t USEL = '{a: 1, b: 2};
  localparam ub_t USCP = '{a: 3, b: 4};
  localparam ub_t UNON = '{a: 5, b: 6};
  localparam ub_t UMOD = '{a: 7, b: 8};
  typedef logic [USEL.a-1:0] uselv_t;
endpackage

module g2q import p2::*; (input logic clk);
  uselv_t sv;
  assign sv = '0;
endmodule

module g2r (output int unsigned o2);
  import p2::*;
  p2::ub_t q;
  assign q = p2::USCP;
  assign o2 = UMOD.a;
endmodule

module g2top(input logic clk);
  int unsigned b2;
  g2q u_q (.clk(clk));
  g2r u_r (.o2(b2));
endmodule

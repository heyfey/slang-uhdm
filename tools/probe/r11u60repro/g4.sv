// g4 — IMPORT KINDS.  wildcard HEADER / wildcard BODY / EXPLICIT header /
// no import at all (scoped use only).
package p4;
  typedef struct { int unsigned a; int unsigned b; } u4_t;
  localparam u4_t B4 = '{a: 4, b: 8};
  typedef logic [B4.a-1:0] v4_t;
endpackage

module g4w import p4::*; (input logic clk);
  v4_t d;
  assign d = '0;
endmodule

module g4b (input logic clk);
  import p4::*;
  v4_t d;
  assign d = '0;
endmodule

module g4e import p4::B4; (input logic clk);
  p4::v4_t d;
  assign d = '0;
endmodule

module g4n (input logic clk);
  p4::v4_t d;
  assign d = '0;
endmodule

module g4top(input logic clk);
  g4w u_w (.clk(clk));
  g4b u_b (.clk(clk));
  g4e u_e (.clk(clk));
  g4n u_n (.clk(clk));
endmodule

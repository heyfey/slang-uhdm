// v8 — the DECLARING PACKAGE selects its own parameter with the SCOPED
// spelling `p8v::SS.a` written INSIDE p8v, beside the bare spelling and a
// never-selected control.  The declaring-package-resolved trigger must accept
// both spellings.
package p8v;
  typedef struct { int unsigned a; int unsigned b; } s8_t;
  localparam s8_t SS = '{a: 4, b: 8};   // selected as p8v::SS.a, inside p8v
  localparam s8_t SB = '{a: 5, b: 9};   // selected as SB.a, inside p8v
  localparam s8_t SN = '{a: 6, b: 10};  // never selected
  typedef logic [p8v::SS.a-1:0] s8v_t;
  typedef logic [SB.a-1:0]      s8b_t;
endpackage

module v8q import p8v::*; (input logic clk);
  s8v_t d; s8b_t e;
  assign d = '0; assign e = '0;
endmodule

module v8top(input logic clk);
  v8q u_q (.clk(clk));
endmodule

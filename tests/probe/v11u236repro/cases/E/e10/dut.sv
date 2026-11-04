// § pkgPatArithLeftParenSpan236 — multiplicative and shift operators
package pk;
  localparam int N = 3;
  typedef struct packed { integer unsigned a; integer unsigned b; } d_s;
  typedef struct packed { integer unsigned a; integer unsigned b; integer unsigned c; } cfg_s;
  localparam d_s q = '{a: 2, b: 5};
  localparam cfg_s p0 = '{a: (N) * (2), b: (N + 1) / 2, c: (N << 1) >> 1};
endpackage
module top (output int o);
  assign o = 1;
endmodule

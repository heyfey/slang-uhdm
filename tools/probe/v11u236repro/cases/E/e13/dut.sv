// § pkgPatArithLeftParenSpan236 — power, relational and logical operators
package pk;
  localparam int N = 3;
  typedef struct packed { integer unsigned a; integer unsigned b; } d_s;
  typedef struct packed { integer unsigned a; integer unsigned b; integer unsigned c; } cfg_s;
  localparam d_s q = '{a: 2, b: 5};
  localparam cfg_s p0 = '{a: (N) ** 2, b: (N > 1) + 1, c: (N == 3) && 1};
endpackage
module top (output int o);
  assign o = 1;
endmodule

// § pkgPatArithLeftParenSpan236 — a member read on the left, a parenthesized right operand only
package pk;
  localparam int N = 3;
  typedef struct packed { integer unsigned a; integer unsigned b; } d_s;
  typedef struct packed { integer unsigned a; integer unsigned b; integer unsigned c; } cfg_s;
  localparam d_s q = '{a: 2, b: 5};
  localparam cfg_s p0 = '{a: (q.a) + 1, b: (q.b) - (q.a), c: N + (1)};
endpackage
module top (output int o);
  assign o = 1;
endmodule

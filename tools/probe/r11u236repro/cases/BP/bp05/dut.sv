// § pkgPatArithLeftParenSpan236 — parenthesized left operands of folded package pattern members
package pk;
  localparam int N = 3;
  typedef struct packed {
    integer unsigned a;
    integer unsigned b;
    integer unsigned c;
    integer unsigned d;
    integer unsigned e;
  } cfg_s;
  localparam cfg_s p0 = '{a: (1 << 2) | (1 << 0), b: ((N * 2)) - 1, c: (N) + 1, d: N * 2 - 1, e: (1 << 1)};
  localparam cfg_s p1 = '{a: (1 << 2)
                              | (1 << 3), b: $clog2(N), c: (N + 1) * 2, d: (N - 1) << 1, e: 9};
endpackage
module top (output int o);
  assign o = 1;
endmodule

// § pkgPatArithLeftParenSpan236 — parenthesized left operands of folded package pattern members: every operator class, nested parentheses, a parameter read
package pk;
  localparam int N = 3;
  typedef struct packed { integer unsigned a; integer unsigned b; } d_s;
  typedef struct packed {
    integer unsigned a; integer unsigned b; integer unsigned c; integer unsigned d;
    integer unsigned e; integer unsigned f; integer unsigned g; integer unsigned h;
  } cfg_s;
  localparam d_s q = '{a: 2, b: 5};
  localparam cfg_s p0 = '{a: (N) * (2), b: ((N)) - 1, c: (q.a) + 1, d: (N + 1) / 2, e: (N << 1) >> 1,
                          f: (N) % 2, g: (N & 1) ^ 1, h: ((1 << N) - 1) & 4};
  localparam cfg_s p1 = '{a: (N) ** 2, b: (N > 1) + 1, c: (q.b) - (q.a), d: ( N ) + 0, e: (N) | (4),
                          f: N + (1), g: (N == 3) && 1, h: (N)};
endpackage
module top (output int o);
  assign o = pk::p0.a + pk::p1.b;
endmodule

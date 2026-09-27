// § hpIdxCallNameSpan184: a call indexing a packed-array base select followed by a member, and a two-level member path
module top;
  typedef struct packed { logic [3:0] v; } ps_t;
  typedef struct packed { ps_t [3:0] w; } pm_t;
  ps_t [3:0] pa;
  pm_t [1:0] pb;
  int k;
  logic [3:0] r1, r2, r3;
  function automatic int f(int x); return x; endfunction
  initial begin
    r1 = pa[f(k)].v;
    r2 = pb[k].w[f(k)].v;
    r3 = pb[f(k)].w[k].v;
  end
endmodule

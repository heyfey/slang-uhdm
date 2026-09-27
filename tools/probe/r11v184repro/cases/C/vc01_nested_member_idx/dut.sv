// § hpIdxCallNameSpan184: a call inside a member-select path nested in a non-trailing index, a call argument, a two-dimensional select and a lvalue index
module top;
  typedef struct packed { logic [3:0] v; } ps_t;
  typedef struct packed { ps_t [3:0] w; } pm_t;
  typedef struct packed { logic [3:0] f; } s_t;
  typedef struct packed { ps_t [1:0][1:0] w2; } p2_t;
  pm_t m;
  p2_t m2;
  s_t s;
  int k;
  logic [3:0] r1, r2, r3, r4;
  logic [15:0] arr;
  function automatic int g(int x); return x; endfunction
  function automatic logic [3:0] h(logic [3:0] x); return x; endfunction
  initial begin
    r1 = m.w[s.f[g(k)]].v;
    r2 = h(m.w[g(k)].v);
    r3 = m2.w2[g(k)][1].v;
    arr[m.w[g(k)].v] = 1'b1;
    r4 = m.w[g(k)].v[g(k)];
  end
endmodule

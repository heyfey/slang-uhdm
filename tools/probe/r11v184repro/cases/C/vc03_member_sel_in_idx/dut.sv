// § hpIdxCallNameSpan184: a call inside a member-select path that is itself a non-trailing index (the inner path's trailing select)
module top;
  typedef struct packed { logic [3:0] v; } ps_t;
  typedef struct packed { ps_t [3:0] w; } pm_t;
  typedef struct packed { logic [3:0] f; } s_t;
  pm_t m;
  s_t s;
  int k;
  logic [3:0] r1;
  logic [15:0] arr;
  function automatic int g(int x); return x; endfunction
  initial r1 = m.w[s.f[g(k)]].v;
endmodule

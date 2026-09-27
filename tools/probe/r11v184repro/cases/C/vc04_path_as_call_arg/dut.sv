// § hpIdxCallNameSpan184: the rvalue path with a call in its non-trailing index is itself a call argument
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
  function automatic logic [3:0] h(logic [3:0] x); return x; endfunction
  initial r1 = h(m.w[g(k)].v);
endmodule

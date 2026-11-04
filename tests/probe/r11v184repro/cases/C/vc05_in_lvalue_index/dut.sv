// § hpIdxCallNameSpan184: the path with a call in its non-trailing index nested in an lvalue's index
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
  initial arr[m.w[g(k)].v] = 1'b1;
endmodule

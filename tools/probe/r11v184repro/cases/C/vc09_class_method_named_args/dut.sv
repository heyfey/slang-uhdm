// § hpIdxCallNameSpan184: a class method's own method call and a call with a named argument in a non-trailing index
typedef struct packed { logic [3:0] v; } ps_t;
typedef struct packed { ps_t [3:0] w; } pm_t;
module top;
  pm_t m;
  int k;
  logic [3:0] r1;
  function automatic int g(int x = 0, int y = 1); return x + y; endfunction
  initial r1 = m.w[g(.y(k))].v;
  class C;
    pm_t cm;
    function int idx(int j); return j; endfunction
    function logic [3:0] rd(int j); return cm.w[idx(j)].v; endfunction
  endclass
endmodule

// § hpIdxCallNameSpan184: a call in the first of two non-trailing selects of one member
module top;
  typedef struct packed { logic [3:0] v; } ps_t;
  typedef struct packed { ps_t [1:0][1:0] w2; } p2_t;
  p2_t m2;
  int k;
  logic [3:0] r1;
  function automatic int g(int x); return x; endfunction
  initial r1 = m2.w2[g(k)][1].v;
endmodule

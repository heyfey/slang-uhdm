// § unitTdClassFormalWriter299
typedef struct packed { int a; int b; } s_t;
`include "h.svh"
module zz;
  function s_t g(s_t y); return y; endfunction
  s_t r;
  initial r = g(r);
endmodule
module top;
  zz u();
endmodule

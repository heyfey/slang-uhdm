// § unitTdClassFormalWriter299
`include "h.svh"
module top;
  function s_t g(s_t y); return y; endfunction
  s_t r;
  initial r = g(r);
endmodule

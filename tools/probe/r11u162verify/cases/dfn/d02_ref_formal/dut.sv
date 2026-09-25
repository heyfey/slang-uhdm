// § dirlessFormalTypeAtName155
package pk; typedef struct packed { logic a; logic b; } s_t; endpackage
module top import pk::*; (output int x);
  function automatic int f(ref s_t [2:0] v); return int'(v); endfunction
  s_t [2:0] q;
  initial x = f(q);
endmodule

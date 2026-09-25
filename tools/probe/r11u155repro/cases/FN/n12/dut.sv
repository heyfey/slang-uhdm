// § dirlessFormalTypeAtName155
package pk; typedef struct packed { logic a; logic b; } s_t; endpackage
module top import pk::*; (input logic [5:0] i, output int x);
  function automatic int f(s_t [2:0] v = 0); return int'(v); endfunction
  assign x = f(i);
endmodule

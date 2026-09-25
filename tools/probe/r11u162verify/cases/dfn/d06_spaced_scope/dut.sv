// § dirlessFormalTypeAtName155
package pk; typedef struct packed { logic a; logic b; } s_t; endpackage
module top (input logic [5:0] i, output int x);
  function automatic int f(pk :: s_t [2:0] v); return int'(v); endfunction
  assign x = f(i);
endmodule

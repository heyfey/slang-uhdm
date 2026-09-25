// § dirlessFormalTypeAtName155
package pk; typedef struct packed { logic a; logic b; } s_t;
  function automatic int f(s_t [2:0] v); return int'(v); endfunction
endpackage
module top (input logic [5:0] i, output int x); assign x = pk::f(i); endmodule

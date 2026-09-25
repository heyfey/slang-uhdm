// § dirlessFormalTypeAtName155
package pk; typedef struct packed { logic a; logic b; } s_t; typedef enum logic [1:0] {A, B} e_t; typedef logic [1:0] v_t; endpackage
module top import pk::*; (input logic [5:0] i, output int x);
  function automatic int f(v_t [2:0] v); return int'(v); endfunction
  assign x = f(i);
endmodule

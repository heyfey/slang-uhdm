// § dirlessFormalTypeAtName155
package pk; typedef struct packed { logic a; logic b; } s_t; endpackage
module top import pk::*; (input logic [5:0] i, output int x);
  function automatic int f(input logic c, input s_t [2:0] v, s_t [1:0] w); return int'(v) + int'(w) + c; endfunction
  assign x = f(1'b0, i, i[3:0]);
endmodule

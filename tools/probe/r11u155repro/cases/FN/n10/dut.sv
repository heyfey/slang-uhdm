// § dirlessFormalTypeAtName155
package pk; typedef struct packed { logic a; logic b; } s_t; endpackage
module top import pk::*; (input logic [5:0] i, output int x);
  task automatic t(s_t [2:0] v); $display(v); endtask
  initial t(i);
  assign x = 0;
endmodule

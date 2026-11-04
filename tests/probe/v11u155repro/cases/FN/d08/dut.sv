// § dirlessFormalTypeAtName155
package pk; typedef struct packed { logic a; logic b; } s_t; typedef enum logic [1:0] {A, B} e_t; typedef logic [1:0] v_t; endpackage
module top import pk::*; (input logic [3:0] i, output int x);
  function automatic int f(const ref s_t [1:0] v); return int'(v); endfunction
  logic [3:0] ii; assign ii = i;
  assign x = 0;
endmodule

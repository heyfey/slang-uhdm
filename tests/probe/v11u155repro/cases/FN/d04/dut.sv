// § dirlessFormalTypeAtName155
package pk; typedef struct packed { logic a; logic b; } s_t; typedef enum logic [1:0] {A, B} e_t; typedef logic [1:0] v_t; endpackage
package pk2; import pk::*; function automatic int f(s_t [1:0] v); return int'(v); endfunction endpackage
module top (input logic [3:0] i, output int x);
  assign x = pk2::f(i);
endmodule

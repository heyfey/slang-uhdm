// § bitsDefNoFoldNoTs421
module top #(parameter w_p = 4) (input logic a);
  typedef struct packed { logic [w_p-1:0] data; logic b; } pk_s;
  localparam int width_lp = $bits(pk_s);
endmodule

// § bitsDefNoFoldNoTs421
module top #(parameter w_p = "inv") (input logic a);
  typedef struct packed { logic [w_p-1:0] data; logic b; } pk_s;
  localparam width_lp = $bits(pk_s);
endmodule

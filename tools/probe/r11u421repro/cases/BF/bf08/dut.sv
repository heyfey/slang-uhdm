// § bitsDefNoFoldNoTs421
module top (input logic a);
  typedef struct packed { logic [3:0] data; logic b; } pk_s;
  localparam width_lp = $bits(pk_s) + 1;
endmodule

// § bitsDefNoFoldNoTs421
module top (input logic a);
  typedef struct packed { logic [3:0] data; logic b; } pk_s;
  pk_s v;
  localparam width_lp = $bits(v);
endmodule

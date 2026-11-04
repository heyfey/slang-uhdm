// § bitsDefNoFoldNoTs421
package p; typedef struct packed { logic [3:0] data; logic b; } pk_s; endpackage
module top (input logic a);
  localparam width_lp = $bits(p::pk_s);
endmodule

// § bitsDefNoFoldNoTs421
package p;
  parameter w_p = 4;
  typedef struct packed { logic [w_p-1:0] data; logic b; } pk_s;
  localparam width_lp = $bits(pk_s);
endpackage
module top; logic [p::width_lp-1:0] x; endmodule

// § bitsDefNoFoldNoTs421
module c #(parameter w_p = 4) (input logic a);
  typedef struct packed { logic [w_p-1:0] data; logic b; } pk_s;
  localparam width_lp = $bits(pk_s);
endmodule
module top; logic a; c #(.w_p(6)) u(a); c v(a); endmodule

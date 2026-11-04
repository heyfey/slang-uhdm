// § bitsDefNoFoldNoTs421
module top #(parameter w_p = 4) (input logic a);
  typedef logic [w_p-1:0] t_t;
  localparam width_lp = $bits(t_t);
endmodule

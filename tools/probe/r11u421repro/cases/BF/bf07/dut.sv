// § bitsDefNoFoldNoTs421
module top (input logic a);
  typedef logic [3:0] t_t;
  localparam width_lp = $bits(t_t);
endmodule

// § bitsDefNoFoldNoTs421
module top #(parameter w_p = 4) (input logic a);
  logic [w_p-1:0] v;
  localparam width_lp = $bits(v);
endmodule

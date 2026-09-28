typedef logic [3:0] w_t;
module dut #(parameter type t = w_t) (input logic s, output t o);
  t [1:0] x;
  assign x[0] = s;
  assign o = x[0];
endmodule

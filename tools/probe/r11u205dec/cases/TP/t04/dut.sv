module dut #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t [1:0] x [3];
  assign x[0][1] = s;
  assign o = x[0][1];
endmodule

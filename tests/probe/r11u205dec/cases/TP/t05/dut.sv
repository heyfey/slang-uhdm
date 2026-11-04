module dut #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t [3:0][1:0] x;
  assign x[0][1] = s;
  assign o = x[0][1];
endmodule

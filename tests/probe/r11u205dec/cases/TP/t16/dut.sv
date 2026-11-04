module dut #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t [3:0] x, z;
  assign x[0] = s;
  assign z[0] = s;
  assign o = x[0] ^ z[0];
endmodule

module dut #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t [1:0] o);
  t y;
  assign y = s;
  assign o[0] = y;
  assign o[1] = y;
endmodule

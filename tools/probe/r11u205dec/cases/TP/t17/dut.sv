module dut #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t [3:0] x;
  always_comb begin : b
    t [1:0] y;
    y[0] = s;
    x[0] = y[0];
  end
  assign o = x[0];
endmodule

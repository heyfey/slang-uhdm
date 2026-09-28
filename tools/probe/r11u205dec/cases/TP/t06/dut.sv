module dut #(parameter int W = 2, parameter type t = logic [W-1:0]) (input logic s, output t o);
  t x;
  for (genvar i = 0; i < 2; i++) begin : g
    t [1:0] y;
    assign y[0] = s;
  end
  assign x = s;
  assign o = x;
endmodule

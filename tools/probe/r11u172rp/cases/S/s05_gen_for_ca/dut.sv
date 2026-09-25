module top #(parameter int W = 8) (input logic [W-1:0] a, input logic [2:0] s, output logic [W-1:0] y [2]);
  for (genvar i = 0; i < 2; i++) begin: g
    assign y[i] = $signed(a) >>> s;
  end
endmodule

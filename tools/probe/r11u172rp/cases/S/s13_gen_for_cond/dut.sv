module top #(parameter int W = 8) (input logic [W-1:0] a, output logic [W-1:0] y);
  for (genvar i = 0; i < $signed(W); i++) begin: g
    assign y[i] = a[i];
  end
endmodule

module top #(parameter type idx_t = logic [1:0]) (input logic a, output logic [1:0] y [3]);
  for (genvar k = 0; k < 3; k++) begin : g
    assign y[k] = idx_t'(a);
  end
endmodule

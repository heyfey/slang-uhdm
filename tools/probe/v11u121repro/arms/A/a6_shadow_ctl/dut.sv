module dut #(parameter type idx_t = logic [1:0]) (input logic s, input logic [3:0] v, output logic [7:0] y [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    typedef logic [3:0] idx_t;
    assign y[k] = s ? idx_t'({v[k], 1'b1}) : idx_t'(v[k]);
  end
endmodule

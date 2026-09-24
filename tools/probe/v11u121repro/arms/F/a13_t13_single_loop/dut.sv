module dut #(parameter int unsigned W = 2, parameter type idx_t = logic [W-1:0]) (input logic s, input logic [3:0] v, output logic [7:0] n);
  for (genvar k = 0; k < 1; k++) begin : g
    if (k == 0) begin : gi
      assign n = s ? idx_t'({1'b1, v[k]}) : idx_t'({1'b0, v[0]});
    end
  end
endmodule

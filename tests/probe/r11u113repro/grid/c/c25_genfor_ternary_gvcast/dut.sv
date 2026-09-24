module top #(parameter int unsigned W = 2, parameter type idx_t = logic [W-1:0]) (input logic a, b, s, input logic [1:0] v, output logic [1:0] n [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    assign n[k] = s ? idx_t'({1'b1, v[unsigned'(k)]}) : idx_t'({1'b0, v[0]});
  end
endmodule

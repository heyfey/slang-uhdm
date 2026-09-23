module top #(parameter int unsigned W = 2, parameter type idx_t = logic [W-1:0]) (input logic a, b, s, output logic [1:0] y, output logic [1:0] z);
  if (1) begin : g
    assign y = {idx_t'(a)};
  end
  assign z = '0;
endmodule

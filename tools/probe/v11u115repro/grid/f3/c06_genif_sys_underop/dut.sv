module top #(parameter int unsigned W = 2, parameter type idx_t = logic [W-1:0]) (input logic a, b, s, output logic [1:0] y, output logic [1:0] z);
  if (1) begin : g
    assign y = $unsigned(idx_t'(a)) + 2'd1;
  end
  assign z = '0;
endmodule

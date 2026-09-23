module top (input logic a, b, s, output logic [1:0] y);
  parameter type idx_t = logic [1:0];
  if (1) begin : g
    assign y = idx_t'(a);
  end
endmodule

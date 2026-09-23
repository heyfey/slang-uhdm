module top #(parameter type idx_t = int) (input logic a, output logic [31:0] y);
  if (1) begin : g
    assign y = idx_t'(a);
  end
endmodule

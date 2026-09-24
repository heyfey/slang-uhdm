module top (input logic a, b, s, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    assign y = idx_t'(a);
  end
endmodule

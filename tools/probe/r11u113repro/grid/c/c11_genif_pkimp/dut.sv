package pk; typedef logic [1:0] idx_t; endpackage
module top import pk::*; (input logic a, b, s, output logic [1:0] y);
  if (1) begin : g
    assign y = idx_t'(a);
  end
endmodule

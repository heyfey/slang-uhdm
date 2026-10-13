// § genCaCastTdAliasScopedName304
module top #(parameter int W = 2) (input logic a, output logic [W-1:0] y);
  typedef logic [W-1:0] idx_t;
  if (W > 1) begin : g
    assign y = idx_t'(a);
  end
endmodule

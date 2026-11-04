// § genCaCastTdAliasScopedName304
module top #(parameter int W = 2) (input logic [3:0] a, output logic [W-1:0] y);
  typedef logic [W-1:0] idx_t;
  for (genvar i = 0; i < 1; i++) begin : g
    assign y = idx_t'(a) ^ idx_t'(i);
  end
endmodule

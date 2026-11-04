// § genCaCastTdAliasScopedName304
module top (input logic a, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  for (genvar i = 0; i < 1; i++) begin : g
    assign y = idx_t'(a);
  end
endmodule

// § genCaCastTdAliasScopedName304
module top (input logic a, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  for (genvar i = 0; i < 1; i++) begin : g
    for (genvar j = 0; j < 1; j++) begin : h
      assign y = idx_t'(a);
    end
  end
endmodule

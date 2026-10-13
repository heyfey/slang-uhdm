// § genCaCastTdAliasScopedName304
module top (input logic a, output logic [3:0] y);
  typedef logic [1:0] idx_t;
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[2*i +: 2] = idx_t'(a);
  end
endmodule

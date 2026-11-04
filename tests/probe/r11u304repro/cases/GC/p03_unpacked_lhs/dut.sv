// § genCaCastTdAliasScopedName304
module top (input logic a, output logic [1:0] oa[2]);
  typedef logic [1:0] idx_t;
  for (genvar i = 0; i < 2; i++) begin : g
    assign oa[i] = idx_t'(a);
  end
endmodule

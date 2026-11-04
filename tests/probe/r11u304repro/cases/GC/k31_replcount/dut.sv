// § genCaCastTdAliasScopedName304
module top (input logic a, output logic [1:0] y);
  typedef logic [2:0] idx_t;
  if (1) begin : g
    assign y = {idx_t'(2){a}};
  end
endmodule

// § genCaCastTdAliasScopedName304
typedef logic [1:0] idx_t;
module top (input logic a, output logic [1:0] y);
  if (1) begin : g
    assign y = idx_t'(a);
  end
endmodule

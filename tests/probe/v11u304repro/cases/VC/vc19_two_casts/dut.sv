// § genCaCastTdAliasScopedName304
module top (input logic [3:0] a, b, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    assign y = idx_t'(a) | idx_t'(b);
  end
endmodule

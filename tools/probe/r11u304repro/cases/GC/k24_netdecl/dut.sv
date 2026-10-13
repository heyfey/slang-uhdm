// § genCaCastTdAliasScopedName304
module top (input logic a, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    wire [1:0] w = idx_t'(a);
    assign y = w;
  end
endmodule

// § genCaCastTdAliasScopedName304
module top (input logic [1:0] a, b, c, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    assign y = (idx_t'(a) == 2'd1) ? b : c;
  end
endmodule

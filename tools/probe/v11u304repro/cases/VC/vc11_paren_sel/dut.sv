// § genCaCastTdAliasScopedName304
module top (input logic [3:0] a, output logic [3:0] y);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    assign y[1:0] = (idx_t'(a));
    assign y[3:2] = 2'b0;
  end
endmodule

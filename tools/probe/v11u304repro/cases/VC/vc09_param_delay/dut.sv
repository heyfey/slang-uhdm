// § genCaCastTdAliasScopedName304
module top (input logic [3:0] a, output logic [1:0] y);
  parameter int D = 2;
  typedef logic [1:0] idx_t;
  if (1) begin : g
    assign #D y = idx_t'(a);
  end
endmodule

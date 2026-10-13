// § genCaCastTdAliasScopedName304
module top (input logic [7:0] a, output logic [2:0] y);
  typedef logic [2:0] idx_t;
  if (1) begin : g
    assign y = a[idx_t'(2):0];
  end
endmodule

// § genCaCastTdAliasScopedName304
module top (input logic [1:0] a, output logic [3:0] y);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    assign y = {idx_t'(a), 2'b0};
  end
endmodule

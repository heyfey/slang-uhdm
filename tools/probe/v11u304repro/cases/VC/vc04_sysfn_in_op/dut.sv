// § genCaCastTdAliasScopedName304
module top (input logic [1:0] a, output logic [2:0] y);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    assign y = $unsigned(idx_t'(a)) + 3'd1;
  end
endmodule

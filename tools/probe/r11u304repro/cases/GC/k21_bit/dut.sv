// § genCaCastTdAliasScopedName304
module top (input logic a, output logic [1:0] y);
  typedef bit [1:0] idx_t;
  if (1) begin : g
    assign y = idx_t'(a);
  end
endmodule

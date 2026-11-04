// § genCaCastTdAliasScopedName304
`define CST(x) idx_t'(x)
module top (input logic a, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    assign y = `CST(a);
  end
endmodule

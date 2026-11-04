// § genCaCastTdAliasScopedName304
module top (input logic [3:0] a, output logic [1:0] y);
  typedef logic [1:0] idx_t;
  if (1) begin : g
    assign q = idx_t'(a) | 2'b00;
  end
  assign y = g.q;
endmodule
